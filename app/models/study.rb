# == Schema Information
#
# Table name: studies
#
#  id                          :integer          not null, primary key
#  study_stage_id              :integer          not null
#  title                       :text             not null
#  reference_number            :text             not null
#  study_type_id               :integer          not null
#  study_setting_id            :integer          not null
#  research_team               :text
#  concept_paper_date          :date             not null
#  protocol_needed             :boolean          not null
#  pre_approved_protocol       :boolean
#  erb_status_id               :integer
#  erb_reference               :text
#  erb_approval_expiry         :date
#  local_erb_submitted         :date
#  local_erb_approved          :date
#  completed                   :date
#  local_collaborators         :text
#  international_collaborators :text
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  other_study_type            :text
#  principal_investigator_id   :integer
#  research_manager_id         :integer
#  country_code                :text
#  feedback_and_suggestions    :text
#  study_topic_id              :integer          not null
#
# Indexes
#
#  index_studies_on_erb_status_id              (erb_status_id)
#  index_studies_on_principal_investigator_id  (principal_investigator_id)
#  index_studies_on_research_manager_id        (research_manager_id)
#  index_studies_on_study_setting_id           (study_setting_id)
#  index_studies_on_study_stage_id             (study_stage_id)
#  index_studies_on_study_topic_id             (study_topic_id)
#  index_studies_on_study_type_id              (study_type_id)
#

class Study < ActiveRecord::Base
  belongs_to :study_stage, inverse_of: :studies
  belongs_to :study_type, inverse_of: :studies
  belongs_to :study_topic, inverse_of: :studies
  belongs_to :study_setting, inverse_of: :studies
  belongs_to :erb_status, inverse_of: :studies
  has_and_belongs_to_many :enabler_barriers, inverse_of: :studies
  belongs_to :principal_investigator,
             class_name: :User,
             inverse_of: :principal_investigator_studies
  belongs_to :research_manager,
             class_name: :User,
             inverse_of: :research_manager_studies
  has_many :study_impacts, inverse_of: :study
  has_many :disseminations, inverse_of: :study
  has_many :publications, inverse_of: :study
  has_many :study_notes, inverse_of: :study
  has_many :documents, inverse_of: :study

  validates :title, presence: true
  validates :reference_number, presence: true
  validates :study_stage, presence: true
  validates :study_type, presence: true
  validates :study_setting, presence: true
  validates :concept_paper_date, presence: true
  validates :study_topic, presence: true
  validates :protocol_needed, inclusion: { in: [true, false] }
  validate :other_study_type_is_set_when_study_type_is_other

  def other_study_type_is_set_when_study_type_is_other
    if study_type == StudyType.other_study_type && other_study_type.blank?
      message = "You must describe the study type if you choose " \
        "\"#{StudyType::OTHER_STUDY_TYPE_NAME}\""
      errors.add(:other_study_type, message)
    end
  end
end
