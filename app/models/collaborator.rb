# == Schema Information
#
# Table name: collaborators
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Collaborator < ActiveRecord::Base
  has_many :study_collaborators, inverse_of: :collaborator
  has_many :studies, through: :study_collaborators

  validates :name, presence: true

  default_scope { order("name ASC") }
end
