FactoryGirl.define do
  factory :study_enabler_barrier do
    study
    enabler_barrier
    sequence(:description) { |n| "Test enabler/barrier #{n}" }
  end
end
