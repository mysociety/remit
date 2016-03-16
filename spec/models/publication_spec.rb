require "rails_helper"
require "support/shared_examples/models/concerns/study_activity_trackable"

RSpec.describe Publication, type: :model do
  # Columns
  it { is_expected.to have_db_column(:study_id).of_type(:integer) }
  it { is_expected.to have_db_column(:doi_number).of_type(:text) }
  it do
    is_expected.to have_db_column(:lead_author).of_type(:text).
      with_options(null: false)
  end
  it do
    is_expected.to have_db_column(:article_title).of_type(:text).
      with_options(null: false)
  end
  it do
    is_expected.to have_db_column(:book_or_journal_title).of_type(:text).
      with_options(null: false)
  end
  it do
    is_expected.to have_db_column(:publication_year).of_type(:integer).
      with_options(null: false)
  end
  it { is_expected.to have_db_column(:user_id).of_type(:integer) }

  # Associations
  it { is_expected.to belong_to(:study).inverse_of(:publications) }
  it { is_expected.to belong_to(:user).inverse_of(:publications) }

  # Validations
  it { is_expected.to validate_presence_of(:lead_author) }
  it { is_expected.to validate_presence_of(:article_title) }
  it { is_expected.to validate_presence_of(:book_or_journal_title) }
  it { is_expected.to validate_presence_of(:publication_year) }

  describe "doi number validation" do
    let(:successful_doi_result) do
      ActiveSupport::JSON.encode(
        message: {
          title: ["Test journal article"],
          publisher: "Test journal",
          issued: { "date-parts" => [[1953, 12, 1]] },
          author: [{ family: "Smith", given: "Jane" }]
        }
      )
    end
    let(:partial_doi_result) do
      ActiveSupport::JSON.encode(
        message: {
          title: ["Test journal article"],
          publisher: "Test journal",
          author: [{ family: "Smith", given: "Jane" }]
        }
      )
    end

    it "skips validation if doi_number is empty" do
      publication = FactoryGirl.build(:publication, doi_number: nil)
      expect(Net::HTTP).not_to receive(:get)
      publication.valid?
      expect(publication.errors).not_to have_key(:doi_number)
    end

    it "sets an error if the lookup fails" do
      publication = FactoryGirl.build(:publication, doi_number: "doi:1234")
      expect(Net::HTTP).to receive(:get).and_return(nil)
      publication.valid?
      expect(publication.errors).to have_key(:doi_number)
    end

    it "sets an error if the lookup returns partial results" do
      publication = FactoryGirl.build(:publication, doi_number: "doi:1234")
      expect(Net::HTTP).to receive(:get).and_return(partial_doi_result)
      publication.valid?
      expect(publication.errors).to have_key(:doi_number)
      expect(publication.errors).to have_key(:publication_year)
    end

    it "doesn't set an error if the lookup succeeds" do
      publication = FactoryGirl.build(:publication, doi_number: "doi:1234")
      expect(Net::HTTP).to receive(:get).and_return(successful_doi_result)
      publication.valid?
      expect(publication.errors).to be_empty
    end
  end

  it_behaves_like "study_activity_trackable"
end
