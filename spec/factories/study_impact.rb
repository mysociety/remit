FactoryGirl.define do
  factory :study_impact do
    study
    impact_type
    sequence(:description) { |n| "Study impact #{n}" }
  end
end
