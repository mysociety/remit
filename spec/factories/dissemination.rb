FactoryGirl.define do
  factory :dissemination do
    dissemination_category
    sequence(:details) { |n| "Dissemination #{n}" }
    fed_back_to_field true
    study
  end
end
