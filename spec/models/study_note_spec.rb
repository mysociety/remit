require "rails_helper"

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

  # Associations
  it { is_expected.to belong_to(:study).inverse_of(:study_notes) }

  # Validation
  it { is_expected.to validate_presence_of(:study) }
  it { is_expected.to validate_presence_of(:notes) }
end
