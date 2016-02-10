# == Schema Information
#
# Table name: study_notes
#
#  id         :integer          not null, primary key
#  notes      :text             not null
#  study_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#
# Indexes
#
#  index_study_notes_on_study_id  (study_id)
#  index_study_notes_on_user_id   (user_id)
#

class StudyNote < ActiveRecord::Base
  include StudyActivityTrackable

  belongs_to :study, inverse_of: :study_notes
  belongs_to :user, inverse_of: :study_notes

  validates :study, presence: true
  validates :notes, presence: true
end
