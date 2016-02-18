# == Schema Information
#
# Table name: study_invites
#
#  id               :integer          not null, primary key
#  study_id         :integer          not null
#  inviting_user_id :integer          not null
#  invited_user_id  :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_study_invites_on_invited_user_id   (invited_user_id)
#  index_study_invites_on_inviting_user_id  (inviting_user_id)
#  index_study_invites_on_study_id          (study_id)
#

# A record for a specific user inviting someone to edit a specific study.
# Note that the invite is separate, because we want people to receive a code
# once, and then be able to access various studies with that code in the
# future.
class StudyInvite < ActiveRecord::Base
  belongs_to :study
  belongs_to :invited_user, class_name: :User
  belongs_to :inviting_user, class_name: :User

  validates :study, presence: true
  validates :invited_user, presence: true
  validates :inviting_user, presence: true
end
