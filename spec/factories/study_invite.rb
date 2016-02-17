FactoryGirl.define do
  factory :study_invite do
    study
    invited_user factory: :user
    inviting_user factory: :user
  end
end
