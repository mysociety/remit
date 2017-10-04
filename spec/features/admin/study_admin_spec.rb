require "rails_helper"
require "support/helpers/features/user_accounts"

RSpec.describe "StudyAdmin" do
  let!(:amr_topic) { FactoryGirl.create(:amr_topic) }
  let!(:brucellosis) { FactoryGirl.create(:brucellosis) }
  let!(:randomised_type) { FactoryGirl.create(:randomised_type) }
  let!(:stable_setting) { FactoryGirl.create(:stable_setting) }
  let!(:collaborator1) { FactoryGirl.create(:collaborator) }
  let!(:collaborator2) { FactoryGirl.create(:collaborator) }
  let(:admin_user) { FactoryGirl.create(:admin_user) }

  before do
    sign_in_account(admin_user.email)
    click_link "Studies"
  end

  it "allows you to create a new study" do
    click_link "New Study"
    fill_in "Title", with: "Test study title"
    select "Operating Center Amsterdam", from: "study_operating_center"
    select Study::STUDY_STAGE_LABELS[:concept], from: "Study stage"
    select amr_topic.name, from: "Study topics"
    select randomised_type.name, from: "Study type"
    select stable_setting.name, from: "Study setting"
    select "United Kingdom", from: "Countries"
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
    expect(study.study_stage).to eq "concept"
    expect(study.study_topics.first).to eq amr_topic
    expect(study.study_type).to eq randomised_type
    expect(study.study_setting).to eq stable_setting
    expect(study.country_codes).to eq %w(GB)
    expect(study.concept_paper_date).to eq Date.new(2015, 1, 1)
  end

  it "allows you to create a new study with multiple countries" do
    click_link "New Study"
    fill_in "Title", with: "Test study title"
    select "Operating Center Amsterdam", from: "study_operating_center"
    select Study::STUDY_STAGE_LABELS[:concept], from: "Study stage"
    select amr_topic.name, from: "Study topics"
    select randomised_type.name, from: "Study type"
    select stable_setting.name, from: "Study setting"
    select "United Kingdom", from: "Countries"
    select "San Marino", from: "Countries"
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
    expect(study.study_stage).to eq "concept"
    expect(study.study_topics.first).to eq amr_topic
    expect(study.study_type).to eq randomised_type
    expect(study.study_setting).to eq stable_setting
    expect(study.country_codes).to match_array %w(GB SM)
    expect(study.concept_paper_date).to eq Date.new(2015, 1, 1)
  end

  it "allows you to create a new study with multiple topics" do
    click_link "New Study"
    fill_in "Title", with: "Test study title"
    select "Operating Center Amsterdam", from: "study_operating_center"
    select Study::STUDY_STAGE_LABELS[:concept], from: "Study stage"
    select amr_topic.name, from: "Study topics"
    select brucellosis.name, from: "Study topics"
    select randomised_type.name, from: "Study type"
    select stable_setting.name, from: "Study setting"
    select "United Kingdom", from: "Countries"
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
    expect(study.study_stage).to eq "concept"
    expect(study.study_topics.first).to eq amr_topic
    expect(study.study_topics.second).to eq brucellosis
    expect(study.study_type).to eq randomised_type
    expect(study.study_setting).to eq stable_setting
    expect(study.country_codes).to eq %w(GB)
    expect(study.concept_paper_date).to eq Date.new(2015, 1, 1)
  end

  it "allows you to create a new study with multiple collaborators" do
    click_link "New Study"
    fill_in "Title", with: "Test study title"
    select "Operating Center Amsterdam", from: "study_operating_center"
    select Study::STUDY_STAGE_LABELS[:concept], from: "Study stage"
    select amr_topic.name, from: "Study topics"
    select randomised_type.name, from: "Study type"
    select stable_setting.name, from: "Study setting"
    select "United Kingdom", from: "Countries"
    within "#study_concept_paper_date_input" do
      select "2015", from: "Year"
      select "January", from: "Month"
      select "1", from: "Day"
    end
    check "Protocol needed"
    select collaborator1.name, from: "Collaborators"
    select collaborator2.name, from: "Collaborators"
    click_button "Create Study"
    expect(page).to have_text "Study was successfully created"
    study = Study.find_by_title("Test study title")
    expect(study).not_to be nil
    expect(study.study_stage).to eq "concept"
    expect(study.study_topics.first).to eq amr_topic
    expect(study.study_type).to eq randomised_type
    expect(study.study_setting).to eq stable_setting
    expect(study.country_codes).to eq %w(GB)
    expect(study.concept_paper_date).to eq Date.new(2015, 1, 1)
    expect(study.collaborators).to match_array([collaborator1, collaborator2])
  end

  context "with an existing study" do
    let!(:accept_status) { FactoryGirl.create(:accept) }
    let!(:study) { FactoryGirl.create(:study) }

    before do
      # An easy way to refresh the page
      click_link "Studies"
    end

    it "allows you to edit the study" do
      click_link "Edit", href: edit_admin_study_path(study)
      select Study::STUDY_STAGE_LABELS[:protocol_erb], from: "Study stage"
      select accept_status.name, from: "Erb status"
      click_button "Update Study"
      expect(page).to have_text "Study was successfully updated"
      expect(study.reload.study_stage).to eq "protocol_erb"
      expect(study.reload.erb_status).to eq accept_status
    end

    it "allows you to delete the study" do
      click_link "Delete", href: admin_study_path(study)
      expect(page).to have_text "Study was successfully destroyed"
      expect(Study.find_by_title(study.title)).to be nil
    end

    it "allows you to hide the study" do
      click_link "Edit", href: edit_admin_study_path(study)
      check "Hidden"
      click_button "Update Study"
      expect(page).to have_text "Study was successfully updated"
      expect(study.reload.hidden).to be true
    end
  end
end
