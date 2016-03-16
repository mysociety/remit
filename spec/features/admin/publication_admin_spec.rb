require "rails_helper"
require "support/helpers/features/user_accounts"

RSpec.describe "PublicationAdmin" do
  let(:admin_user) { FactoryGirl.create(:admin_user) }
  let!(:user) { FactoryGirl.create(:user) }
  let!(:study) { FactoryGirl.create(:study) }

  before do
    sign_in_account(admin_user.email)
    click_link "Publications"
  end

  it "allows you to create a new publication" do
    click_link "New Publication"
    fill_in "Lead author", with: "Test Author"
    fill_in "Article title", with: "Test Article"
    fill_in "Book or journal title", with: "Test Journal"
    fill_in "Publication year", with: "2015"
    select study.title, from: "Study"
    select user.name, from: "User"
    click_button "Create Publication"
    expect(page).to have_text "Publication was successfully created"
    publication = Publication.find_by_lead_author("Test Author")
    expect(publication).not_to be nil
    expect(publication.study).to eq study
    expect(publication.user).to eq user
    expect(publication.article_title).to eq "Test Article"
    expect(publication.book_or_journal_title).to eq "Test Journal"
    expect(publication.publication_year).to eq 2015
  end

  context "with an existing publication" do
    let!(:publication) { FactoryGirl.create(:publication, study: study) }

    before do
      # An easy way to refresh the page
      click_link "Publications"
    end

    it "allows you to edit the publication" do
      click_link "Edit", href: edit_admin_publication_path(publication)
      fill_in "Lead author", with: "Test author updated"
      click_button "Update Publication"
      expect(page).to have_text "Publication was successfully updated"
      expect(publication.reload.lead_author).to eq "Test author updated"
    end

    it "allows you to delete the publication" do
      author = publication.lead_author
      click_link "Delete", href: admin_publication_path(publication)
      expect(page).to have_text "Publication was successfully destroyed"
      expect(Publication.find_by_lead_author(author)).to be nil
    end
  end
end
