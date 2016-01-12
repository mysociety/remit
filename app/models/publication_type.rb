# == Schema Information
#
# Table name: publication_types
#
#  id          :integer          not null, primary key
#  name        :text             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :text
#
# Indexes
#
#  index_publication_types_on_name  (name) UNIQUE
#

class PublicationType < ActiveRecord::Base
  has_many :publications, inverse_of: :publication_type

  validates :name, presence: true, uniqueness: true
end
