require "rails_helper"
require "support/helpers/features/user_accounts"

RSpec.describe "StudyEnablerBarrierAdmin" do
  let(:admin_user) { FactoryGirl.create(:admin_user) }
  let!(:user) { FactoryGirl.create(:user) }
  let!(:study) { FactoryGirl.create(:study) }
  let!(:enabler_barrier) { FactoryGirl.create(:delivery_barrier) }

  before do
    sign_in_account(admin_user.email)
    click_link "Study Enabler Barriers"
  end

  it "allows you to create a new study enabler barrier" do
    click_link "New Study Enabler Barrier"
    select enabler_barrier.name, from: "Enabler barrier"
    select study.title, from: "Study"
    select user.name, from: "User"
    fill_in "Description", with: "Test study enabler"
    click_button "Create Study enabler barrier"
    expect(page).to have_text "Study enabler barrier was successfully created"
    enabler = StudyEnablerBarrier.find_by_description("Test study enabler")
    expect(enabler).not_to be nil
    expect(enabler.study).to eq study
    expect(enabler.user).to eq user
    expect(enabler.enabler_barrier).to eq enabler_barrier
  end

  context "with an existing study_enabler_barrier" do
    let!(:enabler) do
      FactoryGirl.create :study_enabler_barrier,
                         study: study,
                         enabler_barrier: enabler_barrier
    end

    before do
      # An easy way to refresh the page
      click_link "Study Enabler Barriers"
    end

    it "allows you to edit the study_enabler_barrier" do
      click_link "Edit", href: edit_admin_study_enabler_barrier_path(enabler)
      fill_in "Description", with: "Test study enabler updated"
      click_button "Update Study enabler barrier"
      expect(page).to have_text "Study enabler barrier was successfully updated"
      expect(enabler.reload.description).to eq "Test study enabler updated"
    end

    it "allows you to delete the study_enabler_barrier" do
      description = enabler.description
      click_link "Delete", href: admin_study_enabler_barrier_path(enabler)
      expected_text = "Study enabler barrier was successfully destroyed"
      expect(page).to have_text expected_text
      enabler = StudyEnablerBarrier.find_by_description(description)
      expect(enabler).to be nil
    end
  end
end
