require "rails_helper"
require "support/study_contribution_controller_shared_examples"
require "support/study_multiple_resources_controller_shared_examples"

RSpec.describe OutputsController, type: :controller do
  describe "POST #create" do
    let(:study) { FactoryGirl.create(:study) }

    context "when no output type is selected" do
      let(:attributes) do
        {
          study_id: study.id,
          output_type: nil
        }
      end

      before do
        post :create, attributes
      end

      it "renders the study page" do
        expect(response).to render_template("studies/show")
      end

      it "sets a flash alert" do
        expect(flash[:alert]).to eq "Sorry, you have to select an output type."
      end
    end

    context "when the publication output type is selected" do
      let(:valid_attributes) do
        {
          study_id: study.id,
          output_type: "publication",
          publication: {
            article_title: "Article title",
            lead_author: "Lead author",
            book_or_journal_title: "Publication title",
            publication_year: "2015"
          }
        }
      end
      let(:invalid_attributes) do
        {
          study_id: study.id,
          output_type: "publication",
          publication: {
            article_title: "Article title",
          }
        }
      end
      let(:association) { study.publications }
      let(:resource_name) { :publication }
      let(:expected_success_message) { "Publication created successfully" }
      let(:action) { :create }

      it_behaves_like "study contribution controller"
    end

    context "when the dissemination output type is selected" do
      let(:dissemination_category) do
        FactoryGirl.create(:dissemination_category)
      end
      let(:valid_attributes) do
        {
          study_id: study.id,
          output_type: "dissemination",
          dissemination: {
            dissemination_category_id: dissemination_category.id,
            details: "Test dissemination",
            fed_back_to_field: false
          }
        }
      end
      let(:invalid_attributes) do
        {
          study_id: study.id,
          output_type: "dissemination",
          dissemination: {
            details: "Test dissemination",
          }
        }
      end
      let(:association) { study.disseminations }
      let(:resource_name) { :dissemination }
      let(:expected_success_message) { "Dissemination created successfully" }

      it_behaves_like "study contribution controller"
    end

    context "when the study impact output type is selected", :truncation do
      context "when one impact type is submitted" do
        let(:programme_impact) { FactoryGirl.create(:programme_impact) }
        let(:patient_impact) { FactoryGirl.create(:patient_impact) }
        let(:valid_attributes) do
          {
            study_id: study.id,
            output_type: "study_impact",
            study_impact: {
              impact_type_ids: {
                programme_impact.id.to_s => programme_impact.id.to_s
              },
              descriptions: {
                programme_impact.id.to_s => "Test programme impact"
              }
            }
          }
        end
        let(:invalid_attributes) do
          {
            study_id: study.id,
            output_type: "study_impact",
            study_impact: {
              impact_type_ids: {
                programme_impact.id.to_s => programme_impact.id.to_s
              },
              descriptions: {
                patient_impact.id.to_s => "test"
              }
            }
          }
        end
        let(:empty_attributes) do
          {
            study_id: study.id,
            output_type: "study_impact",
            study_impact: {
              impact_type_ids: {},
              descriptions: {}
            }
          }
        end
        let(:association) { study.study_impacts }
        let(:resource_name) { :study_impacts }
        let(:expected_success_message) { "1 Impact created successfully" }
        let(:expected_empty_alert) do
          "Sorry, you have to select at least one type of impact"
        end
        let(:action) { :create }

        it_behaves_like(
          "multiple resources controller when creating one resource")
      end

      context "when multiple impact types are submitted" do
        let(:programme_impact) { FactoryGirl.create(:programme_impact) }
        let(:patient_impact) { FactoryGirl.create(:patient_impact) }
        let(:msf_policy_impact) { FactoryGirl.create(:msf_policy_impact) }
        let(:valid_attributes) do
          {
            study_id: study.id,
            output_type: "study_impact",
            study_impact: {
              impact_type_ids: {
                programme_impact.id.to_s => programme_impact.id.to_s,
                msf_policy_impact.id.to_s => msf_policy_impact.id.to_s
              },
              descriptions: {
                programme_impact.id.to_s => "Test programme impact",
                msf_policy_impact.id.to_s => "Test MSF Policy impact"
              }
            }
          }
        end
        let(:invalid_attributes) do
          {
            study_id: study.id,
            output_type: "study_impact",
            study_impact: {
              impact_type_ids: {
                programme_impact.id.to_s => programme_impact.id.to_s,
                msf_policy_impact.id.to_s => msf_policy_impact.id.to_s
              },
              descriptions: {
                programme_impact.id.to_s => "Test programme impact"
              }
            }
          }
        end
        let(:association) { study.study_impacts }
        let(:resource_name) { :study_impacts }
        let(:expected_success_message) { "2 Impacts created successfully" }
        let(:valid_id) { programme_impact.id }
        let(:invalid_id) { msf_policy_impact.id }
        let(:action) { :create }

        it_behaves_like(
          "multiple resources controller when creating two resources")
      end
    end
  end
end
