FactoryGirl.define do
  factory :study_type, aliases: [:randomised_type] do
    name "Randomised controlled trial (RCT)"

    factory :non_randomised_type do
      name "Non-randomised, controlled trial"
      description "e.g. treatment allocated but allocation not random"
    end

    factory :case_control_type do
      name "Case control study"
    end

    factory :prospective_type do
      name "Cohort study: prospective"
    end

    factory :retrospective_type do
      name "Cohort study: retrospective"
    end

    factory :cross_sectional_type do
      name "Cross-sectional study"
      description "Includes nutrition, mortality, coverage and adherence " \
        "surveys"
    end

    factory :qualitative_type do
      name "Qualitative study"
      description "e.g. main methodology is focus groups or semi-structured" \
        "interviews, etc"
    end

    factory :systematic_review_type do
      name "Systematic review / meta-analysis"
    end

    factory :diagnostic_type do
      name "Diagnostic study"
    end

    factory :epidemiological_type do
      name "Epidemiological study / spatial analysis"
    end

    factory :modelling_type do
      name "Modelling"
    end

    factory :implementation_type do
      name "Implementation study"
      description "Includes feasibility and capitalisation studies"
    end

    factory :descriptive_analysis_type do
      name "Descriptive analysis"
      description "e.g. patient cohort, programme, outbreak, case series, " \
        "case studies"
    end

    factory :ecological_type do
      name "Ecological study"
    end

    factory :mixed_methods_type do
      name "Mixed-methods study"
    end

    factory :other_type do
      name "Other"
      description "Please describe the methodology type clearly"
    end
  end
end
