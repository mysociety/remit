require "rails_helper"

RSpec.describe StudyTopic, type: :model do
  # Columns
  it do
    is_expected.to have_db_column(:name).of_type(:text).
      with_options(null: false)
  end
  it { is_expected.to have_db_column(:description).of_type(:text) }

  # Indexes
  it { is_expected.to have_db_index(:name).unique(true) }

  # Associations
  it do
    is_expected.to have_and_belong_to_many(:studies).inverse_of(:study_topics)
  end

  # Validation
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
end
