# This file should contain all the record creation needed to seed the database
# with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the
# db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Study Types
StudyType.create(
  [
    { name: "Randomised controlled trial (RCT)" },
    { name: "Non-randomised, controlled trial",
      description: "e.g. treatment allocated but allocation not random" },
    { name: "Case control study" },
    { name: "Cohort study: prospective" },
    { name: "Cohort study: retrospective",
      description: "e.g. risk factor study" },
    { name: "Cross-sectional study",
      description: "Includes nutrition, mortality, coverage and adherence " \
        "surveys" },
    { name: "Qualitative study",
      description: "e.g. main methodology is focus groups or " \
        "semi-structured interviews, etc" },
    { name: "Systematic review / meta-analysis" },
    { name: "Diagnostic study" },
    { name: "Epidemiological study / spatial analysis" },
    { name: "Modelling" },
    { name: "Implementation study",
      description: "Includes feasibility and capitalisation studies" },
    { name: "Descriptive analysis",
      description: "e.g. patient cohort, programme, outbreak, case series, " \
        "case studies" },
    { name: "Ecological study" },
    { name: "Mixed-methods study" },
    { name: "Other",
      description: "Please describe the methodology type clearly" },
  ]
)

# MSF Locations
MsfLocation.create(
  [
    { name: "OCA", description: "MSF Operational Centre Amsterdam" },
    { name: "OCB", description: "MSF Operational Centre Brussels" },
    { name: "OCBA", description: "MSF Operational Centre Barcelona-Athens" },
    { name: "OCG", description: "MSF Operational Centre Geneva" },
    { name: "OCP", description: "MSF Operational Centre Paris" },
    { name: "Epicentre" },
    { name: "External", description: "Please describe the location" },
  ]
)

# Study Topics
StudyTopic.create(
  [
    { name: "AMR" },
    { name: "Brucellosis" },
    { name: "Chagas" },
    { name: "Cholera" },
    { name: "Dengue" },
    { name: "Diarrhoea" },
    { name: "HAT" },
    { name: "Heavy metal poisoning" },
    { name: "Hepatitis C" },
    { name: "Hepatitis E" },
    { name: "HIV/AIDS" },
    { name: "Malaria" },
    { name: "Malnutrition" },
    { name: "Maternal & womens health" },
    { name: "Measles" },
    { name: "Meningitis" },
    { name: "Mental health" },
    { name: "Neonatal health" },
    { name: "Neurodevelopment" },
    { name: "Pneumonia" },
    { name: "Sexual violence" },
    { name: "Surgery" },
    { name: "Syphilis" },
    { name: "Tuberculosis" },
    { name: "Typhoid" },
    { name: "Vaccination" },
    { name: "Viral haemorraghic fever" },
    { name: "Visceral leishmaniasis" },
    { name: "Water & sanitation" },
    { name: "Other" },
  ]
)

# Study Settings
StudySetting.create(
  [
    { name: "Stable" },
    { name: "Unstable" },
    { name: "Emergency" },
  ]
)

# Ethical Review Board (ERB) Statuses
ErbStatus.create(
  [
    { name: "Exempt",
      description: "Was marked as exempt from ERB",
      good_bad_or_neutral: "good" },
    { name: "In draft",
      description: "Protocol is in draft",
      good_bad_or_neutral: "neutral" },
    { name: "Submitted",
      description: "Protocol submitted to ERB",
      good_bad_or_neutral: "neutral" },
    { name: "Reject",
      description: "Protocol was rejected by ERB",
      good_bad_or_neutral: "bad" },
    { name: "Re-review",
      description: "Protocol re-submitted to ERB",
      good_bad_or_neutral: "neutral" },
    { name: "Accept",
      description: "Protocol accepted by ERB",
      good_bad_or_neutral: "good" },
  ]
)

# Types of document
DocumentType.create(
  [
    { name: "Protocol" },
    { name: "ERB documentation" },
    { name: "Data sharing agreements" },
    { name: "Study report" },
    { name: "Interim results" },
    { name: "Other" },
  ]
)

# Categories of dissemination
DisseminationCategory.create(
  [
    { name: "Working group",
      dissemination_category_type: "internal", },
    { name: "Internal MSF publication",
      dissemination_category_type: "internal" },
    { name: "MSF conference",
      description: "e.g. MSF Scientific Days or Operational Research Day",
      dissemination_category_type: "internal" },
    { name: "Email group",
      dissemination_category_type: "internal" },
    { name: "Field",
      description: "i.e. mission/project where the study was conducted",
      dissemination_category_type: "internal" },
    { name: "Other internal",
      description: "e.g. other meetings, platforms etc. - please note",
      dissemination_category_type: "internal" },
    { name: "Scientific meeting",
      description: "conference/symposium",
      dissemination_category_type: "external" },
    { name: "Press release or press conference",
      dissemination_category_type: "external" },
    { name: "Talk or presentation",
      description: "please describe the setting",
      dissemination_category_type: "external" },
    { name: "Policy briefing paper",
      dissemination_category_type: "external" },
    { name: "Formal working group, expert panel, advisory body",
      dissemination_category_type: "external" },
    { name: "Magazine, newsletter or online publication",
      description: "blog, website",
      dissemination_category_type: "external" },
    { name: "Bilateral meeting",
      description: "e.g. MoH",
      dissemination_category_type: "internal" },
    { name: "Community involved with research",
      dissemination_category_type: "external" },
    { name: "Other external",
      description: "e.g. other meetings, platforms etc. - please note",
      dissemination_category_type: "external" },
  ]
)

# Types of impact
ImpactType.create(
  [
    { name: "Programmes" },
    { name: "Patients", description: "e.g. morbidity/mortality" },
    { name: "MSF Policy" },
    { name: "External Policy" },
    { name: "Other", description: "e.g. training materials" },
  ]
)

# Statuses for DeliveryUpdates
DeliveryUpdateStatus.create(
  [
    { name: "Progressing fine", good_medium_bad_or_neutral: "good" },
    { name: "Not started", good_medium_bad_or_neutral: "neutral" },
    { name: "Minor problems or delays", good_medium_bad_or_neutral: "medium" },
    { name: "Major problems or delays", good_medium_bad_or_neutral: "bad" },
    { name: "Completed", good_medium_bad_or_neutral: "neutral" }
  ]
)
