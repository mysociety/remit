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

FactoryGirl.define do
  factory :study_collaborator do
    study
    collaborator
  end
end
