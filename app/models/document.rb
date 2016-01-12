# == Schema Information
#
# Table name: documents
#
#  id               :integer          not null, primary key
#  document_type_id :integer          not null
#  study_id         :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_documents_on_document_type_id  (document_type_id)
#  index_documents_on_study_id          (study_id)
#

class Document < ActiveRecord::Base
  belongs_to :document_type, inverse_of: :documents
  belongs_to :study, inverse_of: :documents
  validates :document_type, presence: true
  validates :study, presence: true
end
