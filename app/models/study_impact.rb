# == Schema Information
#
# Table name: study_impacts
#
#  id             :integer          not null, primary key
#  study_id       :integer          not null
#  impact_type_id :integer          not null
#  description    :text             not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_study_impacts_on_impact_type_id  (impact_type_id)
#  index_study_impacts_on_study_id        (study_id)
#

class StudyImpact < ActiveRecord::Base
  include StudyActivityTrackable

  belongs_to :study, inverse_of: :study_impacts
  belongs_to :impact_type, inverse_of: :study_impacts
  validates :study, presence: true
  validates :impact_type, presence: true
  validates :description, presence: true
end
