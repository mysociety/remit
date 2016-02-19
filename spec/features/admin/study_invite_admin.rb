require "rails_helper"
require "support/user_account_feature_helper"

RSpec.describe "StudyInviteAdmin" do
  let(:admin_user) { FactoryGirl.create(:admin_user) }
  let!(:user) { FactoryGirl.create(:user) }
  let!(:user2) { FactoryGirl.create(:user) }
  let!(:study) { FactoryGirl.create(:study) }

  before do
    sign_in_account(admin_user.email)
    click_link "Study Invites"
    # Clear out welcome mails for new users
    ActionMailer::Base.deliveries = []
  end

  it "allows you to create a new study invite" do
    click_link "New Study Invite"
    select study.title, from: "Study"
    select user.name, from: "Inviting user"
    select user2.name, from: "Invited user"
    click_button "Create Study invite"
    expect(page).to have_text "Study invite was successfully created"
    invite = StudyInvite.find_by_study_id(study.id)
    expect(invite).not_to be nil
    expect(invite.inviting_user).to eq user
    expect(invite.invited_user).to eq user2
    invite_mail = ActionMailer::Base.deliveries.last
    expect(invite_mail.to).to eq [user2.email]
  end

  context "with an existing study invite" do
    let!(:invite) { FactoryGirl.create(:study_invite, study: study) }
    let!(:new_user) { FactoryGirl.create(:user) }

    before do
      # An easy way to refresh the page
      click_link "Study Invites"
    end

    it "allows you to edit the study invite" do
      click_link "Edit", href: edit_admin_study_invite_path(invite)
      select new_user.name, from: "Invited user"
      click_button "Update Study invite"
      expect(page).to have_text "Study invite was successfully updated"
      expect(invite.reload.invited_user).to eq new_user
      invite_mail = ActionMailer::Base.deliveries.last
      expect(invite_mail.to).to eq [new_user.email]
    end

    it "allows you to delete the study invite" do
      invited_user = invite.invited_user
      click_link "Delete", href: admin_study_invite_path(invite)
      expect(page).to have_text "Study invite was successfully destroyed"
      expect(StudyInvite.where(invited_user: invited_user)).not_to exist
    end
  end
end
