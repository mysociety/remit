# == Schema Information
#
# Table name: study_settings
#
#  id          :integer          not null, primary key
#  name        :text             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :text
#
# Indexes
#
#  index_study_settings_on_name  (name) UNIQUE
#

class StudySetting < ActiveRecord::Base
  has_many :studies, inverse_of: :study_setting

  validates :name, presence: true, uniqueness: true
end
