require "rails_helper"
require "support/shared_examples/controllers/study_contributions"
# rubocop:disable Metrics/LineLength
require "support/shared_examples/controllers/concerns/creating_multiple_study_resources"
# rubocop:enable Metrics/LineLength
require "support/shared_examples/controllers/concerns/inviting_users"
require "support/shared_examples/controllers/study_management_access_control"
require "support/devise"

RSpec.describe OutputsController, type: :controller do
  let(:pi) { FactoryGirl.create(:user) }
  let(:study) { FactoryGirl.create(:study, principal_investigator: pi) }

  describe "GET #new" do
    it "sets @study" do
      get :new, study_id: study.id
      expect(assigns[:study]).to eq study
    end

    describe "access control" do
      it_behaves_like "study management action" do
        def trigger_action(study)
          get :new, study_id: study.id
        end
      end

      context "with tokens" do
        let!(:invited_user) { FactoryGirl.create(:user) }
        let!(:invite_token) { invited_user.invite_token }
        let!(:invite) do
          FactoryGirl.create(:study_invite, study: study,
                                            invited_user: invited_user,
                                            inviting_user: pi)
        end

        it_behaves_like "inviting users action" do
          def trigger_action(study, token)
            get :new, study_id: study.id, token: token
          end
        end
      end
    end
  end

  describe "POST #create" do
    context "when no output type is selected" do
      let(:attributes) do
        {
          study_id: study.id,
          output_type: nil
        }
      end

      before do
        sign_in pi
        post :create, attributes
      end

      it "renders the new output page" do
        expect(response).to render_template("outputs/new")
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
      let(:expected_success_message) do
        "Publication \"Article title\" added successfully"
      end
      let(:action) { :create }
      let(:expected_error_template) { "outputs/new" }

      it_behaves_like "study contribution controller"

      describe "access control" do
        it_behaves_like "study management action" do
          def trigger_action(study)
            valid_attributes[:study_id] = study.id
            post :create, valid_attributes
          end
        end

        context "when someone's been invited via email" do
          let!(:invited_user) { FactoryGirl.create(:user) }
          let!(:study_invite) do
            FactoryGirl.create(:study_invite, study: study,
                                              invited_user: invited_user,
                                              inviting_user: pi)
          end

          it "allows them in via their invite_token" do
            valid_attributes[:study_id] = study.id
            valid_attributes[:token] = invited_user.invite_token
            post :create, valid_attributes
            expect(response).to have_http_status(:success)
          end
        end
      end
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
            details: "Test dissemination"
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
      let(:expected_success_message) do
        "#{dissemination_category.name} Dissemination added successfully"
      end
      let(:expected_error_template) { "outputs/new" }

      it_behaves_like "study contribution controller"

      describe "access control" do
        it_behaves_like "study management action" do
          def trigger_action(study)
            valid_attributes[:study_id] = study.id
            post :create, valid_attributes
          end
        end

        context "when someone's been invited via email" do
          let!(:invited_user) { FactoryGirl.create(:user) }
          let!(:study_invite) do
            FactoryGirl.create(:study_invite, study: study,
                                              invited_user: invited_user,
                                              inviting_user: pi)
          end

          it "allows them in via their invite_token" do
            valid_attributes[:study_id] = study.id
            valid_attributes[:token] = invited_user.invite_token
            post :create, valid_attributes
            expect(response).to have_http_status(:success)
          end
        end
      end
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
        let(:expected_success_message) { "1 Impact added successfully" }
        let(:expected_empty_alert) do
          "Sorry, you have to select at least one type of impact"
        end
        let(:action) { :create }
        let(:expected_error_template) { "outputs/new" }

        it_behaves_like(
          "multiple resources controller when creating one resource")

        describe "access control" do
          it_behaves_like "study management action" do
            def trigger_action(study)
              valid_attributes[:study_id] = study.id
              post :create, valid_attributes
            end
          end

          context "when someone's been invited via email" do
            let!(:invited_user) { FactoryGirl.create(:user) }
            let!(:study_invite) do
              FactoryGirl.create(:study_invite, study: study,
                                                invited_user: invited_user,
                                                inviting_user: pi)
            end

            it "allows them in via their invite_token" do
              valid_attributes[:study_id] = study.id
              valid_attributes[:token] = invited_user.invite_token
              post :create, valid_attributes
              expect(response).to have_http_status(:success)
            end
          end
        end
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
        let(:expected_success_message) { "2 Impacts added successfully" }
        let(:valid_id) { programme_impact.id }
        let(:invalid_id) { msf_policy_impact.id }
        let(:action) { :create }
        let(:expected_error_template) { "outputs/new" }

        it_behaves_like(
          "multiple resources controller when creating two resources")

        describe "access control" do
          it_behaves_like "study management action" do
            def trigger_action(study)
              valid_attributes[:study_id] = study.id
              post :create, valid_attributes
            end
          end

          context "when someone's been invited via email" do
            let!(:invited_user) { FactoryGirl.create(:user) }
            let!(:study_invite) do
              FactoryGirl.create(:study_invite, study: study,
                                                invited_user: invited_user,
                                                inviting_user: pi)
            end

            it "allows them in via their invite_token" do
              valid_attributes[:study_id] = study.id
              valid_attributes[:token] = invited_user.invite_token
              post :create, valid_attributes
              expect(response).to have_http_status(:success)
            end
          end
        end
      end
    end
  end
end
