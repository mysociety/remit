require "rails_helper"
require "support/user_account_feature_helper"

RSpec.describe "DocumentAdmin" do
  let(:admin_user) { FactoryGirl.create(:admin_user) }
  let!(:study) { FactoryGirl.create(:study) }
  let!(:document_type) { FactoryGirl.create(:protocol_doc_type) }

  before do
    sign_in_account(admin_user.email)
    click_link "Documents"
  end

  it "allows you to create a new document" do
    click_link "New Document"
    select document_type.name, from: "Document type"
    select study.title, from: "Study"
    click_button "Create Document"
    expect(page).to have_text "Document was successfully created"
    document = Document.where(
      "study_id = :study_id AND document_type_id = :document_type_id",
      study_id: study.id,
      document_type_id: document_type.id,
    )
    expect(document).not_to be nil
  end

  context "with an existing document" do
    let!(:document) do
      FactoryGirl.create :document, study: study, document_type: document_type
    end

    before do
      # An easy way to refresh the page
      click_link "Documents"
    end

    it "allows you to edit the document" do
      new_document_type = FactoryGirl.create(:study_report_doc_type)
      click_link "Edit", href: edit_admin_document_path(document)
      select new_document_type.name, from: "Document type"
      click_button "Update Document"
      expect(page).to have_text "Document was successfully updated"
      expect(document.reload.document_type).to eq new_document_type
    end

    it "allows you to delete the document" do
      click_link "Delete", href: admin_document_path(document)
      expect(page).to have_text "Document was successfully destroyed"
      document = Document.where(
        "study_id = :study_id AND document_type_id = :document_type_id",
        study_id: study.id,
        document_type_id: document_type.id,
      )
      expect(document).to be_empty
    end
  end
end
