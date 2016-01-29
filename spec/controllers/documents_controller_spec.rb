require "rails_helper"
require "support/study_contribution_controller_shared_examples"

RSpec.describe DocumentsController, type: :controller do
  describe "POST #create" do
    let(:study) { FactoryGirl.create(:study) }
    let(:document_type) { FactoryGirl.create(:dataset_doc_type) }
    let(:document_upload) do
      fixture_file_upload("test.pdf", "application/pdf")
    end
    let(:valid_attributes) do
      {
        study_id: study.id,
        document: {
          document_type_id: document_type.id,
          document: document_upload
        }
      }
    end
    let(:invalid_attributes) do
      {
        study_id: study.id,
        document: {
          document_type_id: document_type.id
        }
      }
    end
    let(:association) { study.documents }
    let(:resource_name) { :document }
    let(:expected_success_message) { "Document created successfully" }

    it_behaves_like "study contribution controller"
  end
end
