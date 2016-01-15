FactoryGirl.define do
  factory :study do
    sequence(:title) { |n| "Study #{n}" }
    sequence(:reference_number) { |n| "OCA015-#{n}" }
    sequence(:concept_paper_date) { |n| n.weeks.ago }
    protocol_needed true

    # Associations are to things that must have unique names, so we create
    # them in these hooks and look up any existing ones first
    after(:build) do |study|
      concept_stage = StudyStage.find_by_name("Concept")
      study.study_stage = concept_stage || create(:concept_stage)

      rct_stage = StudyType.find_by_name("Randomised controlled trial (RCT)")
      study.study_type = rct_stage || create(:randomised_type)

      stable_setting = StudySetting.find_by_name("Stable")
      study.study_setting = stable_setting || create(:stable_setting)

      study.study_topic = StudyTopic.find_by_name("AMR") || create(:amr_topic)
    end
  end
end
