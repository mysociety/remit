require "rails_helper"
require "support/study_multiple_resources_controller_shared_examples"
require "support/study_management_access_control_shared_examples"

RSpec.describe StudyEnablerBarriersController, type: :controller do
  describe "POST #create_multiple", :truncation do
    let(:user) { FactoryGirl.create(:user) }
    let(:admin_user) { FactoryGirl.create(:admin_user) }
    let(:pi) { FactoryGirl.create(:user) }
    let(:rm) { FactoryGirl.create(:user) }
    let(:study) do
      FactoryGirl.create(:study, principal_investigator: pi,
                                 research_manager: rm)
    end

    context "when one enabler/barrier is submitted" do
      let(:patient_barrier) { FactoryGirl.create(:patient_barrier) }
      let(:delivery_barrier) { FactoryGirl.create(:delivery_barrier) }
      let(:valid_attributes) do
        {
          study_id: study.id,
          study_enabler_barrier: {
            enabler_barrier_ids: {
              patient_barrier.id.to_s => patient_barrier.id.to_s
            },
            descriptions: {
              patient_barrier.id.to_s => "Test patient barrier"
            }
          }
        }
      end
      let(:invalid_attributes) do
        {
          study_id: study.id,
          study_enabler_barrier: {
            enabler_barrier_ids: {
              patient_barrier.id.to_s => patient_barrier.id.to_s
            },
            descriptions: {
              delivery_barrier.id.to_s => "Test delivery barrier"
            }
          }
        }
      end
      let(:empty_attributes) do
        {
          study_id: study.id,
          study_enabler_barrier: {
            enabler_barrier_ids: {},
            descriptions: {}
          }
        }
      end
      let(:association) { study.study_enabler_barriers }
      let(:resource_name) { :study_enabler_barriers }
      let(:expected_success_message) do
        "1 Enabler/Barrier created successfully"
      end
      let(:expected_empty_alert) do
        "Sorry, you have to select at least one type of enabler/barrier"
      end
      let(:action) { :create_multiple }
      let(:expected_error_template) { "studies/show" }

      it_behaves_like "multiple resources controller when creating one resource"

      describe "access control" do
        it_behaves_like "study management action" do
          def trigger_action(study)
            valid_attributes[:study_id] = study.id
            post :create_multiple, valid_attributes
          end
        end
      end
    end

    context "when multiple impact types are submitted" do
      let(:patient_barrier) { FactoryGirl.create(:patient_barrier) }
      let(:delivery_barrier) { FactoryGirl.create(:delivery_barrier) }
      let(:dissemination_barrier) do
        FactoryGirl.create(:dissemination_barrier)
      end
      let(:valid_attributes) do
        {
          study_id: study.id,
          study_enabler_barrier: {
            enabler_barrier_ids: {
              patient_barrier.id.to_s => patient_barrier.id.to_s,
              delivery_barrier.id.to_s => delivery_barrier.id.to_s
            },
            descriptions: {
              patient_barrier.id.to_s => "Test patient barrier",
              delivery_barrier.id.to_s => "Test delivery barrier"
            }
          }
        }
      end
      let(:invalid_attributes) do
        {
          study_id: study.id,
          study_enabler_barrier: {
            enabler_barrier_ids: {
              patient_barrier.id.to_s => patient_barrier.id.to_s,
              delivery_barrier.id.to_s => delivery_barrier.id.to_s
            },
            descriptions: {
              patient_barrier.id.to_s => "Test patient barrier"
            }
          }
        }
      end
      let(:association) { study.study_enabler_barriers }
      let(:resource_name) { :study_enabler_barriers }
      let(:expected_success_message) do
        "2 Enabler/Barriers created successfully"
      end
      let(:valid_id) { patient_barrier.id }
      let(:invalid_id) { delivery_barrier.id }
      let(:action) { :create_multiple }
      let(:expected_success_template) { "studies/show" }
      let(:expected_error_template) { "studies/show" }

      it_behaves_like(
        "multiple resources controller when creating two resources")

      describe "access control" do
        it_behaves_like "study management action" do
          def trigger_action(study)
            valid_attributes[:study_id] = study.id
            post :create_multiple, valid_attributes
          end
        end
      end
    end
  end
end
