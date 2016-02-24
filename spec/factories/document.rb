include ActionDispatch::TestProcess
FactoryGirl.define do
  factory :document do
    study
    document do
      fixture_file_upload(Rails.root.join("spec", "fixtures", "test.pdf"),
                          "application/pdf")
    end

    after(:build) do |d|
      if d.document_type.nil?
        protocol_doc_type = DocumentType.find_by_name("Protocol")
        d.document_type = protocol_doc_type || create(:protocol_doc_type)
      end
    end
  end
end
