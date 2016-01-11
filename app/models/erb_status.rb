# == Schema Information
#
# Table name: erb_statuses
#
#  id         :integer          not null, primary key
#  name       :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_erb_statuses_on_name  (name) UNIQUE
#

class ErbStatus < ActiveRecord::Base
  has_many :studies, inverse_of: :erb_status

  validates :name, presence: true, uniqueness: true
end