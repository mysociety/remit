require "rails_helper"

RSpec.describe Publication, type: :model do
  # Columns
  it do
    is_expected.to have_db_column(:publication_type_id).of_type(:integer).
      with_options(null: false)
  end
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

  # Associations
  it { is_expected.to belong_to(:study).inverse_of(:publications) }
  it { is_expected.to belong_to(:publication_type).inverse_of(:publications) }

  # Validations
  it { is_expected.to validate_presence_of(:publication_type) }
  it { is_expected.to validate_presence_of(:lead_author) }
  it { is_expected.to validate_presence_of(:article_title) }
  it { is_expected.to validate_presence_of(:book_or_journal_title) }
  it { is_expected.to validate_presence_of(:publication_year) }
end
