require "rails_helper"
require "support/helpers/features/user_accounts"

RSpec.describe "DeliveryUpdateInviteAdmin" do
  let(:admin_user) { FactoryGirl.create(:admin_user) }
  let!(:user) { FactoryGirl.create(:user) }
  let!(:study) { FactoryGirl.create(:study) }
  let!(:delivery_update) { FactoryGirl.create(:delivery_update) }

  before do
    sign_in_account(admin_user.email)
    click_link "Delivery Update Invites"
  end

  it "allows you to create a new delivery update invite" do
    click_link "New Delivery Update Invite"
    select study.title, from: "Study"
    select user.name, from: "Invited user"
    select admin_user.name, from: "Inviting user"
    click_button "Create Delivery update invite"
    expect(page).to have_text "Delivery update invite was successfully created"
    invite = DeliveryUpdateInvite.find_by_study_id(study.id)
    expect(invite).not_to be nil
    expect(invite.invited_user).to eq user
    expect(invite.inviting_user).to eq admin_user
  end

  context "with an existing delivery update invite" do
    let!(:invite) do
      FactoryGirl.create :delivery_update_invite,
                         study: study,
                         invited_user: user,
                         inviting_user: admin_user
    end

    before do
      # An easy way to refresh the page
      click_link "Delivery Update Invites"
    end

    it "allows you to edit the delivery update invite" do
      click_link "Edit", href: edit_admin_delivery_update_invite_path(invite)
      select delivery_update.to_s, from: "Delivery update"
      click_button "Update Delivery update invite"
      expect(page).to have_text "Delivery update invite was successfully " \
                                "updated"
      expect(invite.reload.delivery_update).to eq delivery_update
    end

    it "allows you to delete the delivery update invite" do
      click_link "Delete", href: admin_delivery_update_invite_path(invite)
      expect(page).to have_text "Delivery update invite was successfully " \
                                "destroyed"
      expect(DeliveryUpdateInvite.where(study: study)).to be_empty
    end
  end
end
