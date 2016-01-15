FactoryGirl.define do
  factory :study do
    sequence(:title) { |n| "Study #{n}" }
    sequence(:reference_number) { |n| "OCA015-#{n}" }
    sequence(:concept_paper_date) { |n| n.weeks.ago }
    protocol_needed true

    # Associations are to things that must have unique names, so we create
    # them in these hooks and look up any existing ones first
    before(:create) do |study|
      study.study_stage = StudyStage.find_by_name("Concept") || create(:concept_stage)
      study.study_type = StudyType.find_by_name("Randomised controlled trial (RCT)") || create(:randomised_type)
      study.study_setting = StudySetting.find_by_name("Stable") || create(:stable_setting)
      study.study_topic = StudyTopic.find_by_name("AMR") || create(:amr_topic)
    end
  end
end
