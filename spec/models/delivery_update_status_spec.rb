require "rails_helper"

RSpec.describe DeliveryUpdateStatus, type: :model do
  # Columns
  it do
    is_expected.to have_db_column(:name).of_type(:string).
      with_options(null: false)
  end
  it { is_expected.to have_db_column(:description).of_type(:text) }

  # Indexes
  it { is_expected.to have_db_index(:name).unique }

  # Associations
  it do
    is_expected.to have_many(:data_analysis_delivery_updates).
      inverse_of(:data_analysis_status)
  end
  it do
    is_expected.to have_many(:data_collection_delivery_updates).
      inverse_of(:data_collection_status)
  end
  it do
    is_expected.to have_many(:interpretation_and_write_up_delivery_updates).
      inverse_of(:interpretation_and_write_up_status)
  end

  # Validations
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
  it { is_expected.to validate_presence_of(:good_medium_bad_or_neutral) }

  expected_enum_options = {
    good: "good",
    medium: "medium",
    bad: "bad",
    neutral: "neutral"
  }

  it do
    is_expected.to define_enum_for(:good_medium_bad_or_neutral).
      with(expected_enum_options)
  end
end
