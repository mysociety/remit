require "rails_helper"

RSpec.describe ImpactType, type: :model do
  # Columns
  it do
    is_expected.to have_db_column(:name).of_type(:text).
      with_options(null: false)
  end
  it { is_expected.to have_db_column(:description).of_type(:text) }

  # Indexes
  it { is_expected.to have_db_index(:name).unique(true) }

  # Associations
  it { is_expected.to have_many(:study_impacts).inverse_of(:impact_type) }

  # Validation
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
end
