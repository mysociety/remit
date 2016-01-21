require "rails_helper"
require "support/study_activity_trackable_shared_examples"

RSpec.describe EnablerBarrier, type: :model do
  # Columns
  it do
    is_expected.to have_db_column(:name).of_type(:text).
      with_options(null: false)
  end
  it { is_expected.to have_db_column(:description).of_type(:text) }

  # Indexes
  it { is_expected.to validate_presence_of(:name) }

  # Associations
  it do
    is_expected.to have_many(:study_enabler_barriers).
      inverse_of(:enabler_barrier)
  end

  # Validation
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
end
