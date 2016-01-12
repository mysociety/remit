# == Schema Information
#
# Table name: enabler_barriers
#
#  id          :integer          not null, primary key
#  name        :text             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :text
#
# Indexes
#
#  index_enabler_barriers_on_name  (name) UNIQUE
#

class EnablerBarrier < ActiveRecord::Base
  has_and_belongs_to_many :studies, inverse_of: :enabler_barriers

  validates :name, presence: true, uniqueness: true
end
