# == Schema Information
#
# Table name: documents
#
#  id                    :integer          not null, primary key
#  document_type_id      :integer          not null
#  study_id              :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  document_file_name    :string
#  document_content_type :string
#  document_file_size    :integer
#  document_updated_at   :datetime
#
# Indexes
#
#  index_documents_on_document_type_id  (document_type_id)
#  index_documents_on_study_id          (study_id)
#

class Document < ActiveRecord::Base
  include StudyActivityTrackable
  ALLOWED_CONTENT_TYPES = [
    "application/pdf",
    "application/msword",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    "application/vnd.ms-excel",
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    "application/vnd.ms-powerpoint",
    "application/vnd.openxmlformats-officedocument.presentationml.presentation",
  ]

  belongs_to :document_type, inverse_of: :documents
  belongs_to :study, inverse_of: :documents
  validates :document_type, presence: true
  validates :study, presence: true

  has_attached_file :document
  validates_attachment :document,
                       content_type: { content_type: ALLOWED_CONTENT_TYPES }
end
