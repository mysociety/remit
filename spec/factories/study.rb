FactoryGirl.define do
  factory :study do
    study_stage
    sequence(:title) { |n| "Study #{n}" }
    sequence(:reference_number) { |n| "OCA015-#{n}" }
    study_type
    study_setting
    study_topic
    sequence(:concept_paper_date) { |n| n.weeks.ago }
    protocol_needed true
  end
end
