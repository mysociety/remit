require "rails_helper"

RSpec.describe Document, type: :model do
  # Columns
  it do
    is_expected.to have_db_column(:study_id).of_type(:integer).
      with_options(null: false)
  end
  it do
    is_expected.to have_db_column(:document_type_id).of_type(:integer).
      with_options(null: false)
  end

  # Associations
  it { is_expected.to belong_to(:document_type).inverse_of(:documents) }
  it { is_expected.to belong_to(:study).inverse_of(:documents) }

  # Validation
  it { is_expected.to validate_presence_of(:study) }
  it { is_expected.to validate_presence_of(:document_type) }
end
