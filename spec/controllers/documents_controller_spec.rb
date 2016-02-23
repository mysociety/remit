require "rails_helper"
require "support/study_contribution_controller_shared_examples"
require "support/study_management_access_control_shared_examples"
require "support/devise"

RSpec.describe DocumentsController, type: :controller do
  describe "GET #show" do
    let(:user) { FactoryGirl.create(:user) }
    let(:document) { FactoryGirl.create(:document) }

    it "should allow logged in users to access it" do
      sign_in user
      get :show, id: document.id
      expect(response).to have_http_status(:success)
    end

    it "should not allow logged in users to access it" do
      sign_out :user
      get :show, id: document.id
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "POST #create" do
    let(:user) { FactoryGirl.create(:user) }
    let(:admin_user) { FactoryGirl.create(:admin_user) }
    let(:pi) { FactoryGirl.create(:user) }
    let(:rm) { FactoryGirl.create(:user) }
    let(:study) do
      FactoryGirl.create(:study, principal_investigator: pi,
                                 research_manager: rm)
    end
    let(:document_type) { FactoryGirl.create(:erb_documentation_doc_type) }
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
    let(:expected_error_template) { "studies/show" }

    it_behaves_like "study contribution controller"

    describe "access control" do
      it_behaves_like "study management action" do
        def trigger_action(study)
          valid_attributes[:study_id] = study.id
          post :create, valid_attributes
        end
      end
    end
  end
end
