# encoding: utf-8
require "rails_helper"
require "support/user_account_feature_helper"
require "support/matchers/have_latest_activity"
require "support/matchers/match_activity"

def click_label(text)
  find("label", text: text).click
end

RSpec.describe "Contributing to a study" do
  let!(:study) { FactoryGirl.create(:study) }
  let!(:document_type) { FactoryGirl.create(:protocol_doc_type) }
  let!(:dissemination_category) { FactoryGirl.create(:field) }
  let!(:msf_policy_impact_type) { FactoryGirl.create(:msf_policy_impact) }
  let!(:programme_impact_type) { FactoryGirl.create(:programme_impact) }
  let!(:user) { FactoryGirl.create(:normal_user) }

  before do
    PublicActivity.enabled = true
    sign_in_account(user.email)
    visit study_path(study)
  end

  after do
    PublicActivity.enabled = false
  end

  it "allows you to contribute a document" do
    choose("add-document")
    select document_type.name, from: "Document type"
    attach_file "Choose document", "spec/fixtures/test.pdf"
    click_button "Add document"
    document = Document.where(
      "study_id = :study_id AND document_type_id = :document_type_id",
      study_id: study.id,
      document_type_id: document_type.id,
    ).first

    expect(page).to have_text "Document created successfully"
    expect(page).to have_text "#{document_type.name} added by #{user.name}"

    expect(document).not_to be nil
    expect(document.document).not_to be nil
    expect(document.study).to eq study

    expect(study).to have_latest_activity(key: "study.document_added",
                                          owner: user)
  end

  it "allows you to contribute a note" do
    choose("add-note")
    fill_in "Notes", with: "A test note"
    click_button "Add note"
    note = StudyNote.find_by_notes("A test note")

    expect(page).to have_text "Note created successfully"
    expect(page).to have_text "Note left by #{user.name}"
    expect(page).to have_text "A test note"

    expect(note).not_to be nil
    expect(note.study).to eq study
    activity = study.activities.last
    expect(activity.key).to eq "study.study_note_added"
    expect(activity.owner).to eq user
  end

  it "allows you to contribute a publication manually" do
    click_label("Output")
    choose("output-type-publication")
    click_label("Or enter details manually…")
    fill_in "Article title", with: "A test article"
    fill_in "Lead author", with: "A test author"
    fill_in "Publication title", with: "A test publication"
    fill_in "Publication year", with: "2015"
    click_button "Add output"

    publication = Publication.find_by_article_title("A test article")

    expect(page).to have_text "Publication created successfully"
    expect(page).to have_text "Publication added by #{user.name}"

    expect(publication).not_to be nil
    expect(publication.study).to eq study
    expect(study).to have_latest_activity(key: "study.publication_added",
                                          owner: user)
  end

  it "allows you to contribute a dissemination that hasn't been fed back" do
    click_label("Output")
    choose("output-type-dissemination")
    select dissemination_category.name, from: "Dissemination category"
    fill_in "Details", with: "A test dissemination"
    click_button "Add output"

    dissemination = Dissemination.find_by_details("A test dissemination")

    expect(page).to have_text "Dissemination created successfully"
    expect(page).to have_text "Field added by #{user.name}"

    expect(dissemination).not_to be nil
    expect(dissemination.fed_back_to_field).to be false
    expect(dissemination.study).to eq study
    expect(study).to have_latest_activity(key: "study.dissemination_added",
                                          owner: user)
  end

  it "allows you to contribute a dissemination that has been fed back" do
    details = "A test fed back dissemination"

    click_label("Output")
    choose("output-type-dissemination")
    select dissemination_category.name, from: "Dissemination category"
    fill_in "Details", with: details
    check "This has been fed back to the field"
    click_button "Add output"

    dissemination = Dissemination.find_by_details(details)

    expect(page).to have_text "Dissemination created successfully"
    expect(page).to have_text "Field added by #{user.name}"

    expect(dissemination).not_to be nil
    expect(dissemination.fed_back_to_field).to be true
    expect(dissemination.study).to eq study
    expect(study).to have_latest_activity(key: "study.dissemination_added",
                                          owner: user)
  end

  it "allows you to contribute a single impact" do
    click_label("Output")
    choose("output-type-other")
    check "MSF Policy"
    fill_in "study_impact[descriptions][#{msf_policy_impact_type.id}]",
            with: "Test MSF policy impact"
    click_button "Add output"

    impact = StudyImpact.find_by_description("Test MSF policy impact")

    expect(page).to have_text "1 Impact created successfully"
    expect(page).to have_text "MSF Policy impact added by #{user.name}"

    expect(impact).not_to be nil
    expect(impact.study).to eq study
    expect(impact.impact_type).to eq msf_policy_impact_type

    expect(study).to have_latest_activity(key: "study.study_impact_added",
                                          owner: user)
  end

  it "allows you to contribute multiple impacts" do
    click_label("Output")
    choose("output-type-other")
    check "MSF Policy"
    fill_in "study_impact[descriptions][#{msf_policy_impact_type.id}]",
            with: "Test MSF policy impact"
    check "Programmes"
    fill_in "study_impact[descriptions][#{programme_impact_type.id}]",
            with: "Test program impact"
    click_button "Add output"

    msf_impact = StudyImpact.find_by_description("Test MSF policy impact")
    program_impact = StudyImpact.find_by_description("Test program impact")

    expect(page).to have_text "2 Impacts created successfully"
    expect(page).to have_text "MSF Policy impact added by #{user.name}"
    expect(page).to have_text "Programmes impact added by #{user.name}"

    expect(msf_impact).not_to be nil
    expect(msf_impact.study).to eq study
    expect(msf_impact.impact_type).to eq msf_policy_impact_type

    expect(program_impact).not_to be nil
    expect(program_impact.study).to eq study
    expect(program_impact.impact_type).to eq programme_impact_type

    activities = study.activities.first(2)

    expect(activities[0]).to match_activity(key: "study.study_impact_added",
                                            owner: user,
                                            related_content: msf_impact)
    expect(activities[1]).to match_activity(key: "study.study_impact_added",
                                            owner: user,
                                            related_content: program_impact)
  end
end
