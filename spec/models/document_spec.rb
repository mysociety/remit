require "rails_helper"
require "support/shared_examples/models/concerns/study_activity_trackable"

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
  it { is_expected.to have_db_column(:user_id).of_type(:integer) }
  it { is_expected.to have_db_column(:description).of_type(:text) }

  it { should have_attached_file(:document) }

  # Associations
  it { is_expected.to belong_to(:document_type).inverse_of(:documents) }
  it { is_expected.to belong_to(:study).inverse_of(:documents) }
  it { is_expected.to belong_to(:user).inverse_of(:documents) }

  # Validation
  it { is_expected.to validate_presence_of(:study) }
  it { is_expected.to validate_presence_of(:document_type) }

  it { is_expected.to validate_attachment_presence(:document) }
  it do
    is_expected.to validate_attachment_content_type(:document).
      allowing(*Document::ALLOWED_CONTENT_TYPES)
  end

  it_behaves_like "study_activity_trackable"
end
