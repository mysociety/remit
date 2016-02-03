FactoryGirl.define do
  factory :document_type, aliases: [:protocol_doc_type] do
    name "Protocol"

    factory :erb_documentation_doc_type do
      name "ERB documentation"
    end
    factory :data_sharing_doc_type do
      name "Data sharing agreements"
    end
    factory :dataset_doc_type do
      name "Dataset"
    end
    factory :study_report_doc_type do
      name "Study report"
    end
    factory :interim_results_doc_type do
      name "Interim results"
    end
    factory :other_doc_type do
      name "Other"
    end
  end
end
