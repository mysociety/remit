FactoryGirl.define do
  factory :study_topic, aliases: [:amr_topic] do
    name "AMR"

    factory :brucellosis do
      name "Brucellosis"
    end

    factory :chagas do
      name "Chagas"
    end

    factory :cholera do
      name "Cholera"
    end

    factory :dengue do
      name "Dengue"
    end

    factory :diarrhoea do
      name "Diarrhoea"
    end

    factory :hat do
      name "HAT"
    end

    factory :heavy_metal_poisoning do
      name "Heavy metal poisoning"
    end

    factory :hepatitis_c do
      name "Hepatitis C"
    end

    factory :hepatitis_e do
      name "Hepatitis E"
    end

    factory :hiv_aids do
      name "HIV/AIDS"
    end

    factory :malaria do
      name "Malaria"
    end

    factory :malnutrition do
      name "Malnutrition"
    end

    factory :maternal_womens_health do
      name "Maternal & womens health"
    end

    factory :measles do
      name "Measles"
    end

    factory :meningitis do
      name "Meningitis"
    end

    factory :mental_health do
      name "Mental health"
    end

    factory :neonatal_health do
      name "Neonatal health"
    end

    factory :neurodevelopment do
      name "Neurodevelopment"
    end

    factory :pneumonia do
      name "Pneumonia"
    end

    factory :sexual_violence do
      name "Sexual violence"
    end

    factory :surgery do
      name "Surgery"
    end

    factory :syphilis do
      name "Syphilis"
    end

    factory :tuberculosis do
      name "Tuberculosis"
    end

    factory :typhoid do
      name "Typhoid"
    end

    factory :vaccination do
      name "Vaccination"
    end

    factory :viral_haemorraghic_fever do
      name "Viral haemorraghic fever"
    end

    factory :visceral_leishmaniasis do
      name "Visceral leishmaniasis"
    end

    factory :water_sanitation do
      name "Water & sanitation"
    end

    factory :other do
      name "Other"
    end
  end
end
