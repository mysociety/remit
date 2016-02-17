require "rails_helper"

RSpec.describe StudyInvite, type: :model do
  # Columns
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

  # Associations
  it { is_expected.to belong_to(:study) }
  it { is_expected.to belong_to(:invited_user).class_name(:User) }
  it { is_expected.to belong_to(:inviting_user).class_name(:User) }

  # Validation
  it { is_expected.to validate_presence_of(:study) }
  it { is_expected.to validate_presence_of(:invited_user) }
  it { is_expected.to validate_presence_of(:inviting_user) }
  # This should work, but there's a bug in shoulda-matchers
  # https://github.com/thoughtbot/shoulda-matchers/issues/814
  xit do
    is_expected.to validate_uniqueness_of(:study_id).scoped_to(:invited_user)
  end
end
