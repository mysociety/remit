require "rails_helper"
require "support/study_activity_trackable_shared_examples"

RSpec.describe StudyEnablerBarrier, type: :model do
  # Columns
  it do
    is_expected.to have_db_column(:study_id).of_type(:integer).
      with_options(null: false)
  end
  it do
    is_expected.to have_db_column(:enabler_barrier_id).of_type(:integer).
      with_options(null: false)
  end
  it do
    is_expected.to have_db_column(:description).of_type(:text)
  end

  # Associations
  it { is_expected.to belong_to(:study) }
  it { is_expected.to belong_to(:enabler_barrier) }

  # Validation
  it { is_expected.to validate_presence_of(:study) }
  it { is_expected.to validate_presence_of(:enabler_barrier) }

  it_behaves_like "study_activity_trackable"
end
