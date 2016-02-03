FactoryGirl.define do
  factory :study do
    sequence(:title) { |n| "Study #{n}" }
    sequence(:reference_number) { |n| "OCA015-#{n}" }
    sequence(:concept_paper_date) { |n| n.weeks.ago }
    protocol_needed true
    study_stage "concept"

    # Associations are to things that must have unique names, so we create
    # them in these hooks and look up any existing ones first
    after(:build) do |study|
      rct_type = StudyType.find_by_name("Randomised controlled trial (RCT)")
      study.study_type = rct_type || create(:randomised_type)

      stable_setting = StudySetting.find_by_name("Stable")
      study.study_setting = stable_setting || create(:stable_setting)

      if StudyTopic.find_by_name("AMR")
        study.study_topics << StudyTopic.find_by_name("AMR")
      else
        study.study_topics << create(:amr_topic)
      end
    end
  end
end
