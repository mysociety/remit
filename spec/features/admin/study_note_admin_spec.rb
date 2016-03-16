require "rails_helper"
require "support/helpers/features/user_accounts"

RSpec.describe "StudyNoteAdmin" do
  let(:admin_user) { FactoryGirl.create(:admin_user) }
  let!(:user) { FactoryGirl.create(:user) }
  let!(:study) { FactoryGirl.create(:study) }

  before do
    sign_in_account(admin_user.email)
    click_link "Study Notes"
  end

  it "allows you to create a new study note" do
    click_link "New Study Note"
    fill_in "Notes", with: "Test study note"
    select study.title, from: "Study"
    select user.name, from: "User"
    click_button "Create Study note"
    expect(page).to have_text "Study note was successfully created"
    note = StudyNote.find_by_notes("Test study note")
    expect(note).not_to be nil
    expect(note.study).to eq study
    expect(note.user).to eq user
  end

  context "with an existing study note" do
    let!(:note) { FactoryGirl.create(:study_note, study: study) }

    before do
      # An easy way to refresh the page
      click_link "Study Notes"
    end

    it "allows you to edit the study note" do
      click_link "Edit", href: edit_admin_study_note_path(note)
      fill_in "Notes", with: "Test study note updated"
      click_button "Update Study note"
      expect(page).to have_text "Study note was successfully updated"
      expect(note.reload.notes).to eq "Test study note updated"
    end

    it "allows you to delete the study note" do
      notes = note.notes
      click_link "Delete", href: admin_study_note_path(note)
      expect(page).to have_text "Study note was successfully destroyed"
      expect(StudyNote.find_by_notes(notes)).to be nil
    end
  end
end
