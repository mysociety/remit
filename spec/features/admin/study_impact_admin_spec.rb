require "rails_helper"
require "support/user_account_feature_helper"

RSpec.describe "StudyImpactAdmin" do
  let(:admin_user) { FactoryGirl.create(:admin_user) }
  let!(:user) { FactoryGirl.create(:user) }
  let!(:study) { FactoryGirl.create(:study) }
  let!(:impact_type) { FactoryGirl.create(:programme_impact) }

  before do
    sign_in_account(admin_user.email)
    click_link "Study Impacts"
  end

  it "allows you to create a new study impact" do
    click_link "New Study Impact"
    select impact_type.name, from: "Impact type"
    select study.title, from: "Study"
    select user.name, from: "User"
    fill_in "Description", with: "Test study impact"
    click_button "Create Study impact"
    expect(page).to have_text "Study impact was successfully created"
    impact = StudyImpact.find_by_description("Test study impact")
    expect(impact).not_to be nil
    expect(impact.study).to eq study
    expect(impact.user).to eq user
    expect(impact.impact_type).to eq impact_type
  end

  context "with an existing study impact" do
    let!(:impact) do
      FactoryGirl.create :study_impact, study: study,
                                        impact_type: impact_type
    end

    before do
      # An easy way to refresh the page
      click_link "Study Impacts"
    end

    it "allows you to edit the study impact" do
      click_link "Edit", href: edit_admin_study_impact_path(impact)
      fill_in "Description", with: "Test study impact updated"
      click_button "Update Study impact"
      expect(page).to have_text "Study impact was successfully updated"
      expect(impact.reload.description).to eq "Test study impact updated"
    end

    it "allows you to delete the study impact" do
      description = impact.description
      click_link "Delete", href: admin_study_impact_path(impact)
      expect(page).to have_text "Study impact was successfully destroyed"
      impact = StudyImpact.find_by_description(description)
      expect(impact).to be nil
    end
  end
end
