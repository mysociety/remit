require "rails_helper"

RSpec.describe SentAlert, type: :model do
  it do
    is_expected.to have_db_column(:study_id).of_type(:integer).
      with_options(null: false)
  end
  it do
    is_expected.to have_db_column(:user_id).of_type(:integer).
      with_options(null: false)
  end
  it { is_expected.to have_db_column(:alert_type).of_type(:text) }

  # Associations
  it { is_expected.to belong_to(:study) }
  it { is_expected.to belong_to(:user) }

  # Validation
  it { is_expected.to validate_presence_of(:study) }
  it { is_expected.to validate_presence_of(:user) }
  it { is_expected.to validate_presence_of(:alert_type) }

  # Indexes
  it do
    is_expected.to have_db_index([:study_id, :user_id, :alert_type]).unique
  end

  it do
    expected_alert_types = %w(
      delayed_completion
      erb_approval_expiring
      erb_response_overdue)
    is_expected.to validate_inclusion_of(:alert_type).
      in_array(expected_alert_types)
  end
end
