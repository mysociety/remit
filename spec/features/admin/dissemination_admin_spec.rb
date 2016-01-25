require "rails_helper"
require "support/user_account_feature_helper"

RSpec.describe "DisseminationAdmin" do
  let(:admin_user) { FactoryGirl.create(:admin_user) }
  let!(:study) { FactoryGirl.create(:study) }
  let!(:category) { FactoryGirl.create(:working_group_category) }

  before do
    sign_in_account(admin_user.email)
    click_link "Disseminations"
  end

  it "allows you to create a new dissemination" do
    click_link "New Dissemination"
    fill_in "Details", with: "A test dissemination"
    check "Fed back to field"
    select category.name, from: "Dissemination category"
    select study.title, from: "Study"
    click_button "Create Dissemination"
    expect(page).to have_text "Dissemination was successfully created"
    dissemination = Dissemination.find_by_details("A test dissemination")
    expect(dissemination).not_to be nil
    expect(dissemination.study).to eq study
    expect(dissemination.dissemination_category).to eq category
    expect(dissemination.fed_back_to_field).to be true
  end

  context "with an existing dissemination" do
    let!(:dissemination) do
      FactoryGirl.create :dissemination,
                         study: study,
                         dissemination_category: category
    end

    before do
      # An easy way to refresh the page
      click_link "Disseminations"
    end

    it "allows you to edit the dissemination" do
      click_link "Edit", href: edit_admin_dissemination_path(dissemination)
      fill_in "Details", with: "A test dissemination updated"
      click_button "Update Dissemination"
      expect(page).to have_text "Dissemination was successfully updated"
      expect(dissemination.reload.details).to eq "A test dissemination updated"
    end

    it "allows you to delete the dissemination" do
      details = dissemination.details
      click_link "Delete", href: admin_dissemination_path(dissemination)
      expect(page).to have_text "Dissemination was successfully destroyed"
      expect(Dissemination.find_by_details(details)).to be nil
    end
  end
end
