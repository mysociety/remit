require "rails_helper"
require "support/study_contribution_controller_shared_examples"

RSpec.describe StudyNotesController, type: :controller do
  describe "POST #create" do
    let(:study) { FactoryGirl.create(:study) }
    let(:user) { FactoryGirl.create(:user) }
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
  end
end
