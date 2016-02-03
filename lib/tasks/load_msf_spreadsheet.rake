require "csv"

desc "Load MSF's Interim spreadsheet into the DB"
task :load_msf_spreadsheet, [:csv_file] => [:environment] do |_t, args|
  rows = CSV.read(args[:csv_file], headers: true,
                                   header_converters: :symbol,
                                   converters: :all)
  default_topic = StudyTopic.find_by_name!("Other")
  study_topics = [default_topic]
  default_concept_paper_date = Time.zone.today
  default_stage = "concept"
  default_setting = StudySetting.find_by_name!("Stable")
  rows.each do |row|
    next if row[:study_title].blank? || row[:study_reference_].blank?

    # We need to map some of the spreadsheet values to the new data structure
    stage = row[:study_status]
    stage = "delivery" if stage == "Active"
    stage = "protocol_erb" if stage == "Protocol review"
    stage = "concept" if stage == "Concept paper"
    stage = "completion" if stage == "Completed"
    stage = "withdrawn_postponed" if stage == "Postponed / withdrawn"

    unless row[:study_type].blank?
      type = row[:study_type].gsub(/\s\(.*\)/, "")
    end
    type = StudyType.find_by_name(type) || StudyType.find_by_name("Other")
    if type == StudyType.other_study_type
      other_study_type = "Was empty in spreadsheet"
    else
      other_study_type = nil
    end

    if row[:concept_paper_date].blank?
      date = default_concept_paper_date
    else
      date = Date.strptime(row[:concept_paper_date], "%d/%m/%Y")
    end

    country_code = nil
    unless row[:study_location].blank?
      study_location = row[:study_location]
      # The countries gem is very particular about some names
      if study_location == "Democratic Republic of the Congo"
        study_location = "Congo, The Democratic Republic Of The"
      elsif study_location == "Burma"
        study_location = "Myanmar"
      end
      country = ISO3166::Country.find_country_by_name(study_location)
      country_code = country.alpha2 unless country.nil?
    end

    unless row[:disease].blank?
      topics = []
      diseases = row[:disease].split(",")
      diseases.each do |disease|
        if StudyTopic.find_by_name(disease)
          topics << StudyTopic.find_by_name(disease)
        end
      end
      study_topics = topics unless topics.empty?
    end

    Study.create!(
      reference_number: row[:study_reference_],
      title: row[:study_title],
      study_type: type,
      other_study_type: other_study_type,
      study_stage: Study.study_stages[stage] || default_stage,
      concept_paper_date: date,
      study_topics: study_topics,
      # This isn't specified in the CSV at all, so just assume a value
      protocol_needed: true,
      # This isn't specified either
      study_setting: default_setting,
      country_code: country_code
    )
  end
end
