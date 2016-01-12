# == Schema Information
#
# Table name: study_stages
#
#  id         :integer          not null, primary key
#  name       :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_study_stages_on_name  (name) UNIQUE
#

class StudyStage < ActiveRecord::Base
  has_many :studies, inverse_of: :study_stage

  validates :name, presence: true, uniqueness: true
end
