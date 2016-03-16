require "rails_helper"
require "support/shared_examples/models/concerns/study_activity_trackable"

RSpec.describe StudyNote, type: :model do
  # Columns
  it do
    is_expected.to have_db_column(:study_id).of_type(:integer).
      with_options(null: false)
  end
  it do
    is_expected.to have_db_column(:notes).of_type(:text).
      with_options(null: false)
  end
  it { is_expected.to have_db_column(:user_id).of_type(:integer) }

  # Associations
  it { is_expected.to belong_to(:study).inverse_of(:study_notes) }
  it { is_expected.to belong_to(:user).inverse_of(:study_notes) }

  # Validation
  it { is_expected.to validate_presence_of(:study) }
  it { is_expected.to validate_presence_of(:notes) }

  it_behaves_like "study_activity_trackable"
end
