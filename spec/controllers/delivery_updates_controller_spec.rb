require "rails_helper"
require "support/devise"
require "support/shared_examples/controllers/concerns/inviting_users"
require "support/shared_examples/controllers/study_management_access_control"

RSpec.describe DeliveryUpdatesController, type: :controller do
  let(:pi) { FactoryGirl.create(:user) }
  let(:study) { FactoryGirl.create(:study, principal_investigator: pi) }
  let!(:not_started) { FactoryGirl.create(:not_started) }
  let(:status) do
    DeliveryUpdateStatus.find_by_name("Progressing fine") || \
      FactoryGirl.create(:delivery_update_status)
  end

  describe "#new" do
    before do
      sign_in pi
    end

    it "exists" do
      get :new, study_id: study.id
      expect(response.status).to eq 200
    end

    it "sets @study" do
      get :new, study_id: study.id
      expect(assigns[:study]).to eq study
    end

    context "when there's no previous update" do
      it "sets @selected_data_analysis_status" do
        get :new, study_id: study.id
        expect(assigns[:selected_data_analysis_status]).to be_nil
      end

      it "sets @selected_data_collection_status" do
        get :new, study_id: study.id
        expect(assigns[:selected_data_collection_status]).to be_nil
      end

      it "sets @selected_write_up_status" do
        get :new, study_id: study.id
        expect(assigns[:selected_write_up_status]).to be_nil
      end
    end

    context "when there's a previous update" do
      let!(:previous_update) do
        FactoryGirl.create(:delivery_update,
                           study: study,
                           data_analysis_status: not_started,
                           data_collection_status: not_started,
                           interpretation_and_write_up_status: not_started)
      end

      it "sets @selected_data_analysis_status" do
        get :new, study_id: study.id
        expect(assigns[:selected_data_analysis_status]).to(
          eq(previous_update.data_analysis_status.id))
      end

      it "sets @selected_data_collection_status" do
        get :new, study_id: study.id
        expect(assigns[:selected_data_collection_status]).to(
          eq(previous_update.data_collection_status.id))
      end

      it "sets @selected_write_up_status" do
        get :new, study_id: study.id
        expect(assigns[:selected_write_up_status]).to(
          eq(previous_update.interpretation_and_write_up_status.id))
      end
    end

    describe "access control" do
      let!(:invited_user) { FactoryGirl.create(:user) }
      let!(:invite_token) { invited_user.delivery_update_token }
      let!(:invite) do
        FactoryGirl.create(:delivery_update_invite, study: study,
                                                    invited_user: invited_user,
                                                    inviting_user: pi)
      end

      it_behaves_like "study management action" do
        def trigger_action(study)
          get :new, study_id: study.id
        end
      end

      it_behaves_like "inviting users action" do
        def trigger_action(study, token)
          get :new, study_id: study.id, token: token
        end
      end
    end
  end

  describe "#create" do
    let(:valid_attributes) do
      {
        study_id: study.id,
        delivery_update: {
          data_analysis_status_id: status.id,
          data_collection_status_id: status.id,
          interpretation_and_write_up_status_id: status.id,
          comments: "Test comment"
        }
      }
    end

    let(:invalid_attributes) do
      {
        study_id: study.id,
        delivery_update: {
          data_collection_status_id: status.id,
          interpretation_and_write_up_status_id: status.id,
          comments: "Test comment"
        }
      }
    end

    before do
      sign_in pi
    end

    context "given valid data" do
      it "creates a new delivery update" do
        expect do
          post :create, valid_attributes
        end.to change { DeliveryUpdate.count }.by 1
      end

      it "gives the delivery update the right attributes" do
        post :create, valid_attributes
        delivery_update = assigns[:delivery_update]
        expect(delivery_update.study).to eq study
        expect(delivery_update.data_analysis_status).to eq status
        expect(delivery_update.data_collection_status).to eq status
        expect(delivery_update.interpretation_and_write_up_status).to eq status
        expect(delivery_update.comments).to eq "Test comment"
      end

      context "when the user has more studies to update" do
        let(:study2) { FactoryGirl.create(:study, principal_investigator: pi) }
        let(:study3) { FactoryGirl.create(:study, principal_investigator: pi) }
        let!(:study2_invite) do
          FactoryGirl.create(:delivery_update_invite, invited_user: pi,
                                                      study: study2)
        end
        let!(:study3_invite) do
          FactoryGirl.create(:delivery_update_invite, invited_user: pi,
                                                      study: study3)
        end

        it "sets @pending_invites" do
          post :create, valid_attributes
          expect(assigns[:pending_invites]).to(
            match_array([study2_invite, study3_invite]))
        end
      end

      context "when the user has no more studies to update" do
        it "sends @pending_invites to an empty array" do
          post :create, valid_attributes
          expect(assigns[:pending_invites]).to be_empty
        end
      end

      context "when the user is invited" do
        let!(:study_invite) do
          FactoryGirl.create(:delivery_update_invite, invited_user: pi,
                                                      study: study)
        end

        before do
          sign_out :user
        end

        it "sets delivery_update on the invite" do
          attributes = valid_attributes.merge(token: pi.delivery_update_token)
          post :create, attributes
          expect(study_invite.reload.delivery_update).not_to be nil
        end
      end
    end

    context "given invalid data" do
      it "doesn't create a delivery update" do
        expect do
          post :create, invalid_attributes
        end.not_to change { DeliveryUpdate.count }
      end

      it "sets a flash message with an error" do
        post :create, invalid_attributes
        expect(flash[:alert]).to eq "Sorry, looks like we're missing " \
                                    "something, can you double check?"
      end

      context "when there's no previous update" do
        it "sets @selected_data_analysis_status from the supplied data" do
          attributes = valid_attributes.clone
          attributes[:delivery_update][:data_collection_status_id] = nil
          post :create, attributes
          expect(assigns[:selected_data_analysis_status]).to(
            eq(status.id))
        end

        it "sets @selected_data_collection_status from the supplied data" do
          attributes = valid_attributes.clone
          attributes[:delivery_update][:data_analysis_status_id] = nil
          post :create, attributes
          expect(assigns[:selected_data_collection_status]).to(
            eq(status.id))
        end

        it "sets @selected_write_up_status from the supplied data" do
          attributes = valid_attributes.clone
          attributes[:delivery_update][:data_collection_status_id] = nil
          post :create, attributes
          expect(assigns[:selected_write_up_status]).to(
            eq(status.id))
        end
      end

      context "when there's a previous update" do
        let!(:previous_update) do
          FactoryGirl.create(:delivery_update,
                             study: study,
                             data_analysis_status: not_started,
                             data_collection_status: not_started,
                             interpretation_and_write_up_status: not_started)
        end

        context "and the user has made a selection" do
          it "sets @selected_data_analysis_status from the user" do
            attributes = valid_attributes.clone
            attributes[:delivery_update][:data_collection_status_id] = nil
            post :create, attributes
            expect(assigns[:selected_data_analysis_status]).to(
              eq(status.id))
          end

          it "sets @selected_data_collection_status from the user" do
            attributes = valid_attributes.clone
            attributes[:delivery_update][:data_analysis_status_id] = nil
            post :create, attributes
            expect(assigns[:selected_data_collection_status]).to(
              eq(status.id))
          end

          it "sets @selected_write_up_status from the users" do
            attributes = valid_attributes.clone
            attributes[:delivery_update][:data_collection_status_id] = nil
            post :create, attributes
            expect(assigns[:selected_write_up_status]).to(
              eq(status.id))
          end
        end

        context "and the user hasn't made a selection" do
          it "sets @selected_data_analysis_status from the previous" do
            attributes = valid_attributes.clone
            attributes[:delivery_update][:data_analysis_status_id] = nil
            post :create, attributes
            expect(assigns[:selected_data_analysis_status]).to(
              eq(previous_update.data_analysis_status.id))
          end

          it "sets @selected_data_collection_status from the previous" do
            attributes = valid_attributes.clone
            attributes[:delivery_update][:data_collection_status_id] = nil
            post :create, attributes
            expect(assigns[:selected_data_collection_status]).to(
              eq(previous_update.data_collection_status.id))
          end

          it "sets @selected_write_up_status from the previous" do
            attributes = valid_attributes.clone
            # rubocop:disable Metrics/LineLength
            attributes[:delivery_update][:interpretation_and_write_up_status_id] = nil
            # rubocop:enable Metrics/LineLength
            post :create, attributes
            expect(assigns[:selected_write_up_status]).to(
              eq(previous_update.interpretation_and_write_up_status.id))
          end
        end
      end
    end

    describe "access control" do
      let!(:invited_user) { FactoryGirl.create(:user) }
      let!(:invite_token) { invited_user.delivery_update_token }
      let!(:invite) do
        FactoryGirl.create(:delivery_update_invite, study: study,
                                                    invited_user: invited_user,
                                                    inviting_user: pi)
      end

      it_behaves_like "study management action" do
        def trigger_action(study)
          post :create, valid_attributes.merge(study_id: study.id)
        end
      end

      it_behaves_like "inviting users action" do
        def trigger_action(study, token)
          post :create, valid_attributes.merge(study_id: study.id, token: token)
        end
      end
    end
  end
end
