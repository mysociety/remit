require "rails_helper"
require "support/user_account_feature_helper"

RSpec.describe "StudyAdmin" do
  # We need all the stages just for the studies dashboard to work
  let!(:concept_stage) { FactoryGirl.create(:concept_stage) }
  let!(:protocol_stage) { FactoryGirl.create(:protocol_stage) }
  let!(:output_stage) { FactoryGirl.create(:output_stage) }
  let!(:delivery_stage) { FactoryGirl.create(:delivery_stage) }
  let!(:completion_stage) { FactoryGirl.create(:completion_stage) }
  let!(:withdrawn_stage) { FactoryGirl.create(:withdrawn_postponed_stage) }
  let!(:amr_topic) { FactoryGirl.create(:amr_topic) }
  let!(:randomised_type) { FactoryGirl.create(:randomised_type) }
  let!(:stable_setting) { FactoryGirl.create(:stable_setting) }
  let(:admin_user) { FactoryGirl.create(:admin_user) }

  before do
    sign_in_account(admin_user.email)
    click_link "Studies"
  end

  it "allows you to create a new study" do
    click_link "New Study"
    fill_in "Title", with: "Test study title"
    fill_in "Reference number", with: "OCA123-45"
    select concept_stage.name, from: "Study stage"
    select amr_topic.name, from: "Study topic"
    select randomised_type.name, from: "Study type"
    select stable_setting.name, from: "Study setting"
    select "United Kingdom", from: "Country"
    within "#study_concept_paper_date_input" do
      select "2015", from: "Year"
      select "January", from: "Month"
      select "1", from: "Day"
    end
    check "Protocol needed"
    click_button "Create Study"
    expect(page).to have_text "Study was successfully created"
    study = Study.find_by_title("Test study title")
    expect(study).not_to be nil
    expect(study.study_stage).to eq concept_stage
    expect(study.study_topic).to eq amr_topic
    expect(study.study_type).to eq randomised_type
    expect(study.study_setting).to eq stable_setting
    expect(study.country_code).to eq "GB"
    expect(study.concept_paper_date).to eq Date.new(2015, 1, 1)
  end

  context "with an existing study" do
    let!(:study) { FactoryGirl.create(:study) }

    before do
      # An easy way to refresh the page
      click_link "Studies"
    end

    it "allows you to edit the study" do
      click_link "Edit", href: edit_admin_study_path(study)
      select protocol_stage.name, from: "Study stage"
      click_button "Update Study"
      expect(page).to have_text "Study was successfully updated"
      expect(study.reload.study_stage).to eq protocol_stage
    end

    it "allows you to delete the study" do
      click_link "Delete", href: admin_study_path(study)
      expect(page).to have_text "Study was successfully destroyed"
      expect(Study.find_by_title(study.title)).to be nil
    end
  end
end
