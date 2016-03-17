require "rails_helper"
require "support/devise"
require "support/shared_examples/controllers/concerns/inviting_users"
require "support/shared_examples/controllers/study_management_access_control"

RSpec.describe DeliveryUpdatesController, type: :controller do
  let(:pi) { FactoryGirl.create(:user) }
  let(:study) { FactoryGirl.create(:study, principal_investigator: pi) }

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
    let(:status) { FactoryGirl.create(:delivery_update_status) }
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

        it "sets a flash message with links to update each study" do
          post :create, valid_attributes
          expected_message = "Delivery update created successfully.<br><br>" \
                             "You've also got the following studies you need" \
                             " to update:<br><a href=\"" \
                             "#{new_study_delivery_update_path(study2)}\">" \
                             "#{study2.title.truncate(30)}</a>" \
                             "<br><a href=\"" \
                             "#{new_study_delivery_update_path(study3)}\">" \
                             "#{study3.title.truncate(30)}</a>"
          expect(flash[:notice]).to eq expected_message
        end

        context "and the user is using an invite token" do
          let!(:study_invite) do
            FactoryGirl.create(:delivery_update_invite, invited_user: pi,
                                                        study: study)
          end

          before do
            sign_out :user
          end

          it "includes their invite_token in the flash message links" do
            attributes = valid_attributes.merge(token: pi.delivery_update_token)
            post :create, attributes
            expected_message = "Delivery update created successfully.<br><br>" \
                               "You've also got the following studies you " \
                               "need to update:<br><a href=\"" \
                               "#{new_study_delivery_update_path(study2)}?" \
                               "token=#{pi.delivery_update_token}\">" \
                               "#{study2.title.truncate(30)}</a>" \
                               "<br><a href=\"" \
                               "#{new_study_delivery_update_path(study3)}?" \
                               "token=#{pi.delivery_update_token}\">" \
                               "#{study3.title.truncate(30)}</a>"
            expect(flash[:notice]).to eq expected_message
          end
        end
      end

      context "when the user has no more studies to update" do
        it "sets a flash message to say the user is all done" do
          post :create, valid_attributes
          expect(flash[:notice]).to eq "Delivery update created successfully." \
                                       "<br><br>You don't have any more " \
                                       "studies you need to update!"
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
