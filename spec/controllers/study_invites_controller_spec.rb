require "rails_helper"
require "support/devise"
require "support/study_management_access_control_shared_examples"

RSpec.shared_examples_for "successful study invite POST" do
  let(:valid_data) do
    {
      study_id: study.id,
      study_invite: { invited_email: invite_email }
    }
  end

  before do
    post :create, valid_data
  end

  it "creates a study invite" do
    invite = StudyInvite.last
    expect(invite.study).to eq study
    expect(invite.inviting_user).to eq inviting_user
    expect(invite.invited_user.email).to eq invite_email
  end

  it "redirects to the study page" do
    expect(response).to redirect_to(study_path(study))
  end

  it "sends an invite mail to the invited user" do
    mail = ActionMailer::Base.deliveries.last
    expect(mail.to.first).to eq invite_email
  end

  it "sets a flash message" do
    expect(flash[:notice]).to eq "#{invite_email} was invited " \
                                 "successfully. They'll receive an email " \
                                 "with instructions on how to contribute."
  end
end

RSpec.describe StudyInvitesController, type: :controller do
  describe "POST #create" do
    let!(:inviting_user) { FactoryGirl.create(:user) }
    let!(:study) do
      FactoryGirl.create(:study, principal_investigator: inviting_user)
    end
    let!(:existing_user) { FactoryGirl.create(:user) }
    let(:new_email) { "definitely-not-aready-registered@example.com" }

    before do
      # Creating those users will have sent a couple of emails, clear those
      ActionMailer::Base.deliveries = []
    end

    context "when given valid data" do
      before do
        sign_in(inviting_user)
      end

      context "when the invited email address is new" do
        let(:invite_email) { new_email }
        let(:valid_data) do
          {
            study_id: study.id,
            study_invite: { invited_email: invite_email }
          }
        end

        it_behaves_like "successful study invite POST"

        it "creates a new user account for the invited user" do
          post :create, valid_data
          expect(User.where(email: invite_email)).to exist
        end
      end

      context "when the user already exists" do
        let(:invite_email) { existing_user.email }
        it_behaves_like "successful study invite POST"
      end

      context "when something goes wrong sending the email" do
        let(:invite_email) { new_email }
        let(:valid_data) do
          {
            study_id: study.id,
            study_invite: { invited_email: invite_email }
          }
        end

        before do
          expect(StudyInviteMailer).to(
            receive(:invite).and_raise)
          post :create, valid_data
        end

        it "renders studies/show" do
          expect(response).to render_template("studies/show")
        end

        it "sets a flash message" do
          expect(flash[:alert]).to eq "Sorry, something went wrong sending " \
                                      "your invite. Can you try again?"
        end
      end

      it_behaves_like "study management action" do
        def trigger_action(study)
          valid_data = {
            study_id: study.id,
            study_invite: { invited_email: new_email }
          }
          post :create, valid_data
        end
      end
    end

    context "when given invalid data" do
      let(:invalid_data) do
        {
          study_id: study.id,
          study_invite: { invited_email: nil }
        }
      end

      before do
        sign_in(inviting_user)
        post :create, invalid_data
      end

      it "renders studies/show" do
        expect(response).to render_template("studies/show")
      end

      it "sets a flash message" do
        expect(flash[:alert]).to eq "Sorry, looks like we're missing " \
                                    "something, can you double check?"
      end

      it "doesn't create a study invite" do
        expect do
          post :create, invalid_data
        end.not_to change { StudyInvite.count }
      end

      it "doesn't create a user" do
        expect do
          post :create, invalid_data
        end.not_to change { User.count }
      end

      it "doesn't send an invite mail" do
        expect do
          post :create, invalid_data
        end.not_to change { ActionMailer::Base.deliveries.count }
      end
    end
  end
end
