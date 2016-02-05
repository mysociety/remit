FactoryGirl.define do
  factory :study_impact do
    study
    sequence(:description) { |n| "Study impact #{n}" }

    # Impact Types must have unique names, so we create
    # them in this hooks and look up any existing ones first
    after(:build) do |si|
      if si.impact_type.nil?
        policy_impact = ImpactType.find_by_name("MSF Policy")
        si.impact_type = policy_impact || create(:msf_policy_impact)
      end
    end
  end
end
