# == Schema Information
#
# Table name: study_enabler_barriers
#
#  id                 :integer          not null, primary key
#  study_id           :integer          not null
#  enabler_barrier_id :integer          not null
#  description        :text             not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  user_id            :integer
#
# Indexes
#
#  index_study_enabler_barriers_on_enabler_barrier_id  (enabler_barrier_id)
#  index_study_enabler_barriers_on_study_id            (study_id)
#  index_study_enabler_barriers_on_user_id             (user_id)
#

class StudyEnablerBarrier < ActiveRecord::Base
  include StudyActivityTrackable

  belongs_to :study, inverse_of: :study_enabler_barriers
  belongs_to :enabler_barrier, inverse_of: :study_enabler_barriers
  belongs_to :user, inverse_of: :study_enabler_barriers

  validates :study, presence: true
  validates :enabler_barrier, presence: true
  validates :description, presence: true
end
