require "rails_helper"

RSpec.describe DeliveryUpdateInvite, type: :model do
  it do
    is_expected.to have_db_column(:study_id).of_type(:integer).
      with_options(null: false)
  end
  it do
    is_expected.to have_db_column(:invited_user_id).of_type(:integer).
      with_options(null: false)
  end
  it do
    is_expected.to have_db_column(:inviting_user_id).of_type(:integer).
      with_options(null: false)
  end
  it { is_expected.to have_db_column(:delivery_update_id).of_type(:integer) }

  it { is_expected.to belong_to(:study).inverse_of(:delivery_update_invites) }
  it { is_expected.to belong_to(:invited_user).class_name(:User) }
  it { is_expected.to belong_to(:inviting_user).class_name(:User) }
  it do
    is_expected.to belong_to(:delivery_update).
      inverse_of(:delivery_update_invites)
  end

  it { is_expected.to validate_presence_of(:study) }
  it { is_expected.to validate_presence_of(:invited_user) }
  it { is_expected.to validate_presence_of(:inviting_user) }
end
