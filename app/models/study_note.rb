# == Schema Information
#
# Table name: study_notes
#
#  id         :integer          not null, primary key
#  notes      :text             not null
#  study_id   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_study_notes_on_study_id  (study_id)
#

class StudyNote < ActiveRecord::Base
  belongs_to :study, inverse_of: :study_notes

  validates :study, presence: true
  validates :notes, presence: true
end
