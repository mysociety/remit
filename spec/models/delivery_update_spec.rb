require "rails_helper"

RSpec.describe DeliveryUpdate, type: :model do
  # Columns
  it { is_expected.to have_db_column(:study_id).of_type(:integer) }
  it do
    is_expected.to have_db_column(:data_analysis_status_id).of_type(:integer)
  end
  it do
    is_expected.to have_db_column(:data_collection_status_id).of_type(:integer)
  end
  it do
    is_expected.to have_db_column(:interpretation_and_write_up_status_id).
      of_type(:integer)
  end
  it { is_expected.to have_db_column(:user_id).of_type(:integer) }
  it { is_expected.to have_db_column(:comments).of_type(:text) }

  # Associations
  it { is_expected.to belong_to(:study).inverse_of(:delivery_updates) }
  it do
    is_expected.to belong_to(:data_analysis_status).
      class_name(:DeliveryUpdateStatus)
  end
  it do
    is_expected.to belong_to(:data_collection_status).
      class_name(:DeliveryUpdateStatus)
  end
  it do
    is_expected.to belong_to(:interpretation_and_write_up_status).
      class_name(:DeliveryUpdateStatus)
  end
  it { is_expected.to belong_to(:user).inverse_of(:delivery_updates) }

  # Validations
  it { is_expected.to validate_presence_of(:study) }
  it { is_expected.to validate_presence_of(:data_analysis_status) }
  it { is_expected.to validate_presence_of(:data_collection_status) }
  it do
    is_expected.to validate_presence_of(:interpretation_and_write_up_status)
  end
  it { is_expected.to validate_presence_of(:user) }
end
