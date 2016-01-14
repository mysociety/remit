require "csv"

desc "Load MSF's Interim spreadsheet into the DB"
task :load_msf_spreadsheet, [:csv_file] => [:environment] do |_t, args|
  rows = CSV.read(args[:csv_file], headers: true,
                                   header_converters: :symbol,
                                   converters: :all)
  default_topic = StudyTopic.find_by_name!("Other")
  default_concept_paper_date = Time.zone.today
  default_stage = StudyStage.find_by_name!("Concept")
  default_setting = StudySetting.find_by_name!("Stable")
  rows.each do |row|
    next if row[:study_title].blank? || row[:study_reference_].blank?

    # We need to map some of the spreadsheet values to the new data structure
    stage = row[:study_status]
    stage = "Delivery" if stage == "Active"
    stage = "Protocol & ERB" if stage == "Protocol review"
    stage = "Concept" if stage == "Concept paper"
    stage = "Completion" if stage == "Completed"
    stage = "Withdrawn or Postponed" if stage == "Postponed / withdrawn"

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

    Study.create!(
      reference_number: row[:study_reference_],
      title: row[:study_title],
      study_type: type,
      other_study_type: other_study_type,
      study_stage: StudyStage.find_by_name(stage) || default_stage,
      concept_paper_date: date,
      study_topic: StudyTopic.find_by_name(row[:disease]) || default_topic,
      # This isn't specified in the CSV at all, so just assume a value
      protocol_needed: true,
      # This isn't specified either
      study_setting: default_setting
    )
  end
end
