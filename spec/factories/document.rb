include ActionDispatch::TestProcess
FactoryGirl.define do
  factory :document do
    study
    document_type
    document do
      fixture_file_upload(Rails.root.join("spec", "fixtures", "test.pdf"),
                          "application/pdf")
    end
  end
end
