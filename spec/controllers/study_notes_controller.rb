require "rails_helper"
require "support/shared_examples/controllers/study_contributions"
require "support/shared_examples/controllers/study_management_access_control"

RSpec.describe StudyNotesController, type: :controller do
  describe "POST #create" do
    let(:user) { FactoryGirl.create(:user) }
    let(:admin_user) { FactoryGirl.create(:admin_user) }
    let(:pi) { FactoryGirl.create(:user) }
    let(:rm) { FactoryGirl.create(:user) }
    let(:study) do
      FactoryGirl.create(:study, principal_investigator: pi,
                                 research_manager: rm)
    end
    let(:valid_attributes) do
      {
        study_id: study.id,
        study_note: {
          notes: "A test note"
        }
      }
    end
    let(:invalid_attributes) do
      {
        study_id: study.id,
        study_note: {
          notes: nil
        }
      }
    end
    let(:association) { study.study_notes }
    let(:resource_name) { :study_note }
    let(:expected_success_message) { "Study note created successfully" }
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
