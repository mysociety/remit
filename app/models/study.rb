# == Schema Information
#
# Table name: studies
#
#  id                          :integer          not null, primary key
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
#  study_stage                 :enum             default("concept"), not null
#
# Indexes
#
#  index_studies_on_erb_status_id              (erb_status_id)
#  index_studies_on_principal_investigator_id  (principal_investigator_id)
#  index_studies_on_research_manager_id        (research_manager_id)
#  index_studies_on_study_setting_id           (study_setting_id)
#  index_studies_on_study_topic_id             (study_topic_id)
#  index_studies_on_study_type_id              (study_type_id)
#

class Study < ActiveRecord::Base
  # Include the base class for PublicActivity because we don't want to track
  # everything about this, just some specific things
  include PublicActivity::Common
  ACTIVITY_TRACKED_ATTRS = %w(study_stage erb_status_id title
                              principal_investigator_id research_manager_id
                              local_erb_submitted local_erb_approved
                              completed).freeze

  STUDY_STAGE_LABELS = {
    concept: "Concept",
    protocol_erb: "Protocol & ERB",
    delivery: "Delivery",
    output: "Output",
    completion: "Completion",
    withdrawn_postponed: "Withdrawn or Postponed",
  }.freeze
  # Options for dropdowns have to be label => value
  STUDY_STAGE_OPTIONS = STUDY_STAGE_LABELS.invert.freeze

  after_save :log_changes

  enum study_stage: {
    concept: "concept",
    protocol_erb: "protocol_erb",
    delivery: "delivery",
    output: "output",
    completion: "completion",
    withdrawn_postponed: "withdrawn_postponed",
  }

  belongs_to :study_type, inverse_of: :studies
  belongs_to :study_topic, inverse_of: :studies
  belongs_to :study_setting, inverse_of: :studies
  belongs_to :erb_status, inverse_of: :studies
  belongs_to :principal_investigator,
             class_name: :User,
             inverse_of: :principal_investigator_studies
  belongs_to :research_manager,
             class_name: :User,
             inverse_of: :research_manager_studies
  has_many :study_enabler_barriers, inverse_of: :study
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

  def country
    return if country_code.blank?
    country = ISO3166::Country.new(country_code)
    country.name unless country.nil?
  end

  # Create a new PublicActivity record for any changes to attributes we care
  # about.
  def log_changes
    if changes.key? "id"
      # We treat this specially because it signifies the model being created
      # but the changes hash will have lots of other attributes in too, which
      # we don't want to create activities for.
      create_activity :created
    else
      changes.each do |attr_name, change|
        next unless ACTIVITY_TRACKED_ATTRS.include? attr_name
        before = change[0]
        after = change[1]
        key = "#{attr_name}_changed".to_sym
        params = { attribute: attr_name, before: before, after: after }
        owner = proc { |c, _m| c.current_user unless c.nil? }
        create_activity key, parameters: params, owner: owner
      end
    end
  end

  def study_stage_label
    STUDY_STAGE_LABELS[study_stage.to_sym]
  end

  # When did this study enter the stage it's currently in?
  def study_stage_since
    study_change = latest_stage_change
    if study_change.blank?
      created_at
    else
      study_change.created_at
    end
  end

  # Return the most recent study change activity
  def latest_stage_change
    activities.
      where(key: "study.study_stage_changed").
      order(created_at: :desc).
      take
  end

  # Has the title ever changed for this study?
  def title_changed?
    activities.where(key: "study.title_changed").exists?
  end

  # What was the original title (if the title hasn't changed, this just
  # returns the current title)
  def original_title
    change = activities.where(key: "study.title_changed").first
    return change.parameters[:before] if change.present?
    title
  end
end
