FactoryGirl.define do
  factory :msf_location, aliases: [:oca_location] do
    name "OCA"
    description "MSF Operational Centre Amsterdam"

    factory :ocb_location do
      name "OCB"
      description "MSF Operational Centre Brussels"
    end

    factory :ocba_location do
      name "OCBA"
      description "MSF Operational Centre Barcelona-Athens"
    end

    factory :ocg_location do
      name "OCG"
      description "MSF Operational Centre Geneva"
    end

    factory :ocp_location do
      name "OCP"
      description "MSF Operational Centre Paris"
    end

    factory :epicentre_location do
      name "Epicentre"
    end

    factory :external_location do
      name "External"
      description "Please describe the location"
    end
  end
end
