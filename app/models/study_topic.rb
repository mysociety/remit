# == Schema Information
#
# Table name: study_topics
#
#  id          :integer          not null, primary key
#  name        :text             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :text
#
# Indexes
#
#  index_study_topics_on_name  (name) UNIQUE
#

class StudyTopic < ActiveRecord::Base
  has_many :studies, inverse_of: :study_topic

  validates :name, presence: true, uniqueness: true
end
