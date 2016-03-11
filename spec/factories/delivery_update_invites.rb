# == Schema Information
#
# Table name: delivery_update_invites
#
#  id                 :integer          not null, primary key
#  study_id           :integer          not null
#  invited_user_id    :integer          not null
#  inviting_user_id   :integer          not null
#  delivery_update_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_delivery_update_invites_on_delivery_update_id  (delivery_update_id)
#  index_delivery_update_invites_on_invited_user_id     (invited_user_id)
#  index_delivery_update_invites_on_inviting_user_id    (inviting_user_id)
#  index_delivery_update_invites_on_study_id            (study_id)
#

FactoryGirl.define do
  factory :delivery_update_invite do
    study
    invited_user factory: :user
    inviting_user factory: :user
  end
end
