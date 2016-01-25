FactoryGirl.define do
  factory :study_note do
    sequence(:notes) { |n| "Test study note #{n}" }
    study
  end
end
