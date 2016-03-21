# encoding: utf-8
require "rails_helper"
require "support/helpers/features/user_accounts"
require "support/matchers/have_latest_activity"
require "support/matchers/match_activity"

def click_label(text)
  find("label", text: text).click
end

RSpec.describe "Contributing to a study" do
  let!(:document_type) { FactoryGirl.create(:protocol_doc_type) }
  let!(:dissemination_category) { FactoryGirl.create(:field) }
  let!(:msf_policy_impact_type) { FactoryGirl.create(:msf_policy_impact) }
  let!(:programme_impact_type) { FactoryGirl.create(:programme_impact) }
  let!(:user) { FactoryGirl.create(:normal_user) }
  let!(:study) { FactoryGirl.create(:study, principal_investigator: user) }

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
    expect(document.user).to eq user

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
    expect(note.user).to eq user
    activity = study.activities.last
    expect(activity.key).to eq "study.study_note_added"
    expect(activity.owner).to eq user
  end
end
