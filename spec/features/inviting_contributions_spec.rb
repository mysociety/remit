# encoding: utf-8
require "rails_helper"
require "support/user_account_feature_helper"

def click_label(text)
  find("label", text: text).click
end

RSpec.describe "Inviting a contributor" do
  let(:user) { FactoryGirl.create(:normal_user) }
  let(:study) { FactoryGirl.create(:study, principal_investigator: user) }

  before do
    sign_in_account(user.email)
    visit study_path(study)
  end

  it "allows you to invite a user" do
    click_label("Invite someone else to record an impact")
    fill_in "Email address:", with: "invited@example.com"
    click_button "Send"
    expect(page).to have_text("invited@example.com was invited " \
                              "successfully. They'll receive an email " \
                              "with instructions on how to contribute.")
    expect(ActionMailer::Base.deliveries.last.to).to eq ["invited@example.com"]
    invited_user = User.where(email: "invited@example.com")
    expect(invited_user).to exist
    invite = StudyInvite.where(study: study,
                               invited_user: invited_user,
                               inviting_user: user)
    expect(invite).to exist
  end
end
