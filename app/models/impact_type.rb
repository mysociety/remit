# == Schema Information
#
# Table name: impact_types
#
#  id          :integer          not null, primary key
#  name        :text             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :text
#
# Indexes
#
#  index_impact_types_on_name  (name) UNIQUE
#

class ImpactType < ActiveRecord::Base
  has_many :study_impacts, inverse_of: :impact_type

  validates :name, presence: true, uniqueness: true

  default_scope { order("name ASC") }
end
