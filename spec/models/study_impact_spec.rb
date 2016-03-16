require "rails_helper"
require "support/shared_examples/models/concerns/study_activity_trackable"

RSpec.describe StudyImpact, type: :model do
  # Columns
  it do
    is_expected.to have_db_column(:study_id).of_type(:integer).
      with_options(null: false)
  end
  it do
    is_expected.to have_db_column(:impact_type_id).of_type(:integer).
      with_options(null: false)
  end
  it do
    is_expected.to have_db_column(:description).of_type(:text).
      with_options(null: false)
  end
  it { is_expected.to have_db_column(:user_id).of_type(:integer) }

  # Associations
  it { is_expected.to belong_to(:study).inverse_of(:study_impacts) }
  it { is_expected.to belong_to(:impact_type) }
  it { is_expected.to belong_to(:user).inverse_of(:study_impacts) }

  # Validation
  it { is_expected.to validate_presence_of(:study) }
  it { is_expected.to validate_presence_of(:impact_type) }
  it { is_expected.to validate_presence_of(:description) }

  it_behaves_like "study_activity_trackable"
end
