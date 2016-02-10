require "rails_helper"

RSpec.describe ErbStatus, type: :model do
  # Columns
  it do
    is_expected.to have_db_column(:name).of_type(:text).
      with_options(null: false)
  end

  it do
    is_expected.to have_db_column(:description).of_type(:text).
      with_options(null: false)
  end

  it do
    is_expected.to have_db_column(:good_bad_or_neutral).of_type(:enum).
      with_options(null: false, default: "neutral")
  end

  # Indexes
  it { is_expected.to have_db_index(:name).unique(true) }

  # Associations
  it { is_expected.to have_many(:studies).inverse_of(:erb_status) }

  # Validation
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
  it { is_expected.to validate_presence_of(:description) }
  it { is_expected.to validate_presence_of(:good_bad_or_neutral) }
end
