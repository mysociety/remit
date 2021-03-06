FactoryGirl.define do
  factory :dissemination do
    sequence(:details) { |n| "Dissemination #{n}" }
    study

    # Dissemination categories must have unique names, so we create
    # them in this hooks and look up any existing ones first
    after(:build) do |d|
      if d.dissemination_category.nil?
        email_group = DisseminationCategory.find_by_name("Email group")
        d.dissemination_category = email_group || create(:email_group)
      end
    end
  end
end
