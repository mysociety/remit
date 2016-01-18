FactoryGirl.define do
  factory :impact_type, aliases: [:programme_impact] do
    name "Programmes"

    factory :patient_impact do
      name "Patients"
      description "e.g. morbidity/mortality"
    end
    factory :msf_policy_impact do
      name "MSF Policy"
    end
    factory :external_policy_impact do
      name "External Policy"
    end
    factory :other_impact do
      name "Other"
      description "e.g. training materials"
    end
  end
end
