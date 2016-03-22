# rubocop:disable Metrics/LineLength
# == Schema Information
#
# Table name: study_collaborators
#
#  id              :integer          not null, primary key
#  study_id        :integer          not null
#  collaborator_id :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_study_collaborators_on_collaborator_id               (collaborator_id)
#  index_study_collaborators_on_study_id                      (study_id)
#  index_study_collaborators_on_study_id_and_collaborator_id  (study_id,collaborator_id) UNIQUE
#
# rubocop:enable Metrics/LineLength

class StudyCollaborator < ActiveRecord::Base
  belongs_to :study, inverse_of: :study_collaborators
  belongs_to :collaborator, inverse_of: :study_collaborators

  validates :study, presence: true
  validates :collaborator, presence: true
  validates :collaborator_id, uniqueness: { scope: :study_id }
end
