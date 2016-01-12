# == Schema Information
#
# Table name: document_types
#
#  id          :integer          not null, primary key
#  name        :text             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :text
#
# Indexes
#
#  index_document_types_on_name  (name) UNIQUE
#

class DocumentType < ActiveRecord::Base
  has_many :documents, inverse_of: :document_type

  validates :name, presence: true, uniqueness: true
end
