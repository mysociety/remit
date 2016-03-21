# encoding: utf-8
require "rails_helper"
require "support/helpers/features/user_accounts"

RSpec.describe "Adding delivery updates" do
  let!(:user) { FactoryGirl.create(:normal_user) }
  let!(:study) { FactoryGirl.create(:study, principal_investigator: user) }
  let!(:progressing_fine) { FactoryGirl.create(:progressing_fine) }
  let!(:major_problems) { FactoryGirl.create(:major_problems) }
  let!(:invite) do
    FactoryGirl.create(:delivery_update_invite, study: study,
                                                invited_user: user)
  end

  it "lets a logged in user add an update" do
    sign_in_account(user.email)
    visit study_path(study)
    find(:xpath, "//a[@href='#{new_study_delivery_update_path(study)}']").click
    select progressing_fine.name, from: "Data collection"
    select progressing_fine.name, from: "Data analysis"
    select major_problems.name, from: "Interpretation and write up"
    click_button "Add delivery update"

    expect(page).to have_text "Delivery update created successfully"
  end

  it "lets invited users add an update without signing in" do
    path = new_study_delivery_update_path(study)
    visit "#{path}?token=#{user.delivery_update_token}"
    select progressing_fine.name, from: "Data collection"
    select progressing_fine.name, from: "Data analysis"
    select major_problems.name, from: "Interpretation and write up"
    click_button "Add delivery update"

    expect(page).to have_text "Delivery update created successfully"
  end
end
