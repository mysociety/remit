require "csv"
require "securerandom"

desc "Load MSF's Interim spreadsheet into the DB"
task :load_msf_spreadsheet, [:csv_file] => [:environment] do |_t, args|
  rows = CSV.read(args[:csv_file], headers: true,
                                   header_converters: :symbol,
                                   converters: :all)
  default_topic = StudyTopic.find_by_name!("Other")
  study_topics = [default_topic]
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
      date = nil
    else
      date = Date.strptime(row[:concept_paper_date], "%d/%m/%Y")
    end

    if row[:data_collection_completed_date].blank?
      completed_date = nil
    else
      completed_date = Date.strptime(row[:data_collection_completed_date],
                                     "%d/%m/%Y")
    end

    country_codes = []
    unless row[:study_location].blank?
      study_locations = row[:study_location].split(",")
      study_locations.each do |study_location|
        # The countries gem is very particular about some names
        if study_location == "Democratic Republic of the Congo"
          study_location = "Congo, The Democratic Republic Of The"
        elsif study_location == "Burma"
          study_location = "Myanmar"
        end
        country = ISO3166::Country.find_country_by_name(study_location)
        unless country.nil?
          country_codes << country.alpha2
        end
      end
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

    if row[:erb_reference].blank?
      erb_reference = nil
      erb_status = ErbStatus.find_by_name("Exempt")
      protocol_needed = false
    else
      erb_reference = row[:erb_reference]
      status = row[:erb_status]
      status = "Submitted" if status == "In submission"
      erb_status = ErbStatus.find_by_name(status)
      if erb_status.blank?
        erb_status = ErbStatus.find_by_name("In draft")
      end
      protocol_needed = true
    end

    pi = get_or_create_user(row)

    Study.create!(
      reference_number: row[:study_reference_],
      title: row[:study_title],
      study_type: type,
      other_study_type: other_study_type,
      study_stage: Study.study_stages[stage] || default_stage,
      concept_paper_date: date,
      study_topics: study_topics,
      # This isn't specified in the CSV at all, so just assume a value
      protocol_needed: protocol_needed,
      # This isn't specified either
      study_setting: default_setting,
      country_codes: country_codes,
      erb_reference: erb_reference,
      erb_status: erb_status,
      principal_investigator: pi,
      completed: completed_date
    )
  end
end

def get_or_create_user(row)
  pi = nil
  unless row[:pi_email].blank?
    # See if we've already created a user before - some have multiple
    # studies
    pi = User.find_by_email(row[:pi_email].downcase)
    if pi.blank?
      pi = create_user(row)
    end
  end
  pi
end

def create_user(row)
  # Create an new confirmed user account but don't send them an email
  # about it.
  name = "#{row[:pi_firstname]} #{row[:pi_surname]}"
  password = SecureRandom.urlsafe_base64(16)
  location = MsfLocation.find_by_name(row[:pi_section])
  external_location = nil
  if location && location.name == "External"
    external_location = row[:pi_section_text]
    unless external_location
      location = nil
      external_location = "External location text is required but was " \
                          "not given"
    end
  end
  pi = User.new(
    name: name,
    email: row[:pi_email].downcase,
    password: password,
    password_confirmation: password,
    msf_location: location,
    external_location: external_location)
  pi.skip_confirmation!
  pi.save!
  pi
end
