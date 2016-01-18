FactoryGirl.define do
  factory :enabler_barrier, aliases: [:delivery_barrier] do
    name "Enablers/barriers to study delivery"

    factory :dissemination_barrier do
      name "Enablers/barriers to dissemination or uptake of results"
    end
    factory :patient_barrier do
      name "Enablers/barriers to patient recruitment"
    end
  end
end
