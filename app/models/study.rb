# == Schema Information
#
# Table name: studies
#
#  id                        :integer          not null, primary key
#  title                     :text             not null
#  reference_number          :text             not null
#  study_type_id             :integer          not null
#  study_setting_id          :integer          not null
#  research_team             :text
#  concept_paper_date        :date
#  protocol_needed           :boolean          not null
#  pre_approved_protocol     :boolean
#  erb_status_id             :integer
#  erb_reference             :text
#  erb_approval_expiry       :date
#  local_erb_submitted       :date
#  local_erb_approved        :date
#  completed                 :date
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  other_study_type          :text
#  principal_investigator_id :integer
#  research_manager_id       :integer
#  country_codes             :text
#  study_stage               :enum             default("concept"), not null
#  expected_completion_date  :date
#  erb_submitted             :date
#  erb_approved              :date
#  hidden                    :boolean          default(FALSE)
#  delivery_delayed          :boolean          default(FALSE), not null
#
# Indexes
#
#  index_studies_on_erb_status_id              (erb_status_id)
#  index_studies_on_principal_investigator_id  (principal_investigator_id)
#  index_studies_on_research_manager_id        (research_manager_id)
#  index_studies_on_study_setting_id           (study_setting_id)
#  index_studies_on_study_type_id              (study_type_id)
#

class Study < ActiveRecord::Base
  # Include the base class for PublicActivity because we don't want to track
  # everything about this, just some specific things
  include PublicActivity::Common
  ACTIVITY_TRACKED_ATTRS = %w(study_stage erb_status_id title
                              principal_investigator_id research_manager_id
                              erb_submitted erb_approved local_erb_submitted
                              local_erb_approved completed).freeze

  STUDY_STAGE_LABELS = {
    concept: "Concept",
    protocol_erb: "Protocol & ERB",
    delivery: "Delivery",
    completion: "Completion",
    withdrawn_postponed: "Withdrawn or Postponed",
    archived: "Archived",
  }.freeze
  # Options for dropdowns have to be label => value
  STUDY_STAGE_OPTIONS = STUDY_STAGE_LABELS.invert.freeze

  # Tooltips for the stage labels
  STUDY_STAGE_DESCRIPTIONS = {
    concept: "This stage is all concept papers that have been approved by " \
             "a medical manager",
    protocol_erb: "This stage is for all protocols that have been approved " \
                  "by a medical manager and (if not exempt) submitted to " \
                  "the MSF Ethics Review Board",
    delivery: "This stage encompasses all phases of a study being " \
              "&lsquo;in progress&rsquo; i.e. data collection, data " \
              "analysis and write up.",
    completion: "A study is considered completed after the first study " \
                "report has been written up.",
    withdrawn_postponed: "",
    archived: "",
  }.freeze

  after_save :log_changes

  enum study_stage: {
    concept: "concept",
    protocol_erb: "protocol_erb",
    delivery: "delivery",
    completion: "completion",
    withdrawn_postponed: "withdrawn_postponed",
  }

  belongs_to :study_type, inverse_of: :studies
  belongs_to :study_setting, inverse_of: :studies
  belongs_to :erb_status, inverse_of: :studies
  belongs_to :principal_investigator,
             class_name: :User,
             inverse_of: :principal_investigator_studies
  belongs_to :research_manager,
             class_name: :User,
             inverse_of: :research_manager_studies
  has_and_belongs_to_many :study_topics, inverse_of: :studies
  has_many :study_impacts, inverse_of: :study
  has_many :disseminations, inverse_of: :study
  has_many :publications, inverse_of: :study
  has_many :study_notes, inverse_of: :study
  has_many :documents, inverse_of: :study
  has_many :sent_alerts, inverse_of: :study
  has_many :study_invites, inverse_of: :study
  has_many :invited_users, through: :study_invites
  has_many :delivery_updates, inverse_of: :study
  has_many :delivery_update_invites, inverse_of: :study
  has_many :delivery_update_invited_users, through: :delivery_update_invites,
                                           source: :invited_user
  has_many :study_collaborators, inverse_of: :study
  has_many :collaborators, through: :study_collaborators

  validates :title, presence: true
  validates :reference_number, presence: true
  validates :study_stage, presence: true
  validates :study_type, presence: true
  validates :study_setting, presence: true
  validates :study_topics, presence: true
  validates :erb_status, presence: true, if: :erb_status_needed?
  validates :protocol_needed, inclusion: { in: [true, false] }
  validate :other_study_type_is_set_when_study_type_is_other

  def self.visible
    where(hidden: false)
  end

  def self.active
    query = <<-SQL
        study_stage = 'delivery'
        OR study_stage = 'completion'
    SQL
    not_archived_or_withdrawn.where(query)
  end

  def self.archived
    completion.where("completed IS NOT NULL AND completed < ?", archive_date)
  end

  def self.not_archived
    query = <<-SQL
      study_stage = 'completion'
      AND completed IS NOT NULL
      AND completed < ?
    SQL
    where.not(query, archive_date)
  end

  def self.not_withdrawn
    where.not(study_stage: :withdrawn_postponed)
  end

  def self.not_archived_or_withdrawn
    not_withdrawn.not_archived
  end

  def self.delayed_completing
    query = <<-SQL
      completed IS NULL
      AND expected_completion_date IS NOT NULL
      AND expected_completion_date < ?
    SQL
    where(query, Time.zone.today)
  end

  def self.erb_approval_expiring
    query = <<-SQL
      study_stage = 'delivery'
      AND ( erb_approval_expiry IS NOT NULL AND erb_approval_expiry < ?)
    SQL
    where(query, Study.erb_approval_expiry_warning_at)
  end

  def self.erb_response_overdue
    submitted = ErbStatus.submitted_status
    query = <<-SQL
      erb_status_id = ?
      AND erb_submitted IS NOT NULL
      AND erb_submitted < ?
    SQL
    where(query, submitted.id, Study.erb_response_overdue_at)
  end

  def self.delivery_delayed
    # Studies whose most recent delivery update has one or more delays in it
    where(delivery_delayed: true)
  end

  # Return the studies which will trigger a flag to PIs/RMs
  def self.flagged
    flagged = delayed_completing
    flagged += erb_approval_expiring
    flagged += erb_response_overdue
    flagged += delivery_delayed
    flagged.uniq
  end

  # Return studies in a particular country
  def self.in_country(code)
    where("country_codes LIKE ?", "%#{code}%")
  end

  # Return the count of studies with some kind of recorded impact
  # XXX - this should probably come from some kind of counter-cache on the
  # studies table, not from three separate queries to the DB
  def self.impactful_count
    with_publications = joins(:publications).select(:id)
    with_impacts = joins(:study_impacts).select(:id)
    with_disseminations = joins(:disseminations).select(:id)
    impactful = with_disseminations + with_impacts + with_publications
    impactful.uniq.count
  end

  # What's the cutoff date for studies being archived
  def self.archive_date
    Time.zone.today - 5.years
  end

  def self.erb_approval_expiry_warning_at
    Time.zone.today + 1.month
  end

  def self.erb_response_overdue_at
    Time.zone.today - 3.months
  end

  def self.to_csv
    CSV.generate(headers: true) do |csv|
      csv << csv_headers

      all.find_each do |study|
        csv << study.csv_row
      end
    end
  end

  # Return the (fixed) set of column headers for a CSV of studies
  def self.csv_headers
    [
      "Report ID",
      "Study Title",
      "Study Type",
      "Other Study Type",
      "Study Locations",
      "Topics",
      "Study Stage: Added",
      "Study Stage: Protocol & ERB",
      "Study Stage: Delivery",
      "Study Stage: Completion",
      "Study Stage: Withdrawn/Postponed",
      "Concept Paper Date",
      "Pre-approved Protocol",
      "Protocol URL",
      "ERB Reference",
      "ERB Status",
      "ERB Submitted",
      "ERB Approved",
      "ERB Expiry",
      "Local ERB Submitted",
      "Local ERB Approved",
      "Collaborators",
      "Notes",
      "Documents",
      "Outputs: # Publications",
      "Outputs: # Dissmination",
      "Outputs: # Other Impact"
    ]
  end

  # Return an array of values for a CSV row representing this study
  def csv_row
    stage_dates = stage_change_dates
    [
      reference_number,
      title,
      study_type.name,
      other_study_type,
      country_names,
      study_topic_names,
      formatted_date(created_at),
      formatted_date(stage_dates[:protocol_change]),
      formatted_date(stage_dates[:delivery_change]),
      formatted_date(stage_dates[:completion_change]),
      formatted_date(stage_dates[:withdrawn_change]),
      formatted_date(concept_paper_date),
      protocol_needed ? "Yes" : "No",
      protocol_url,
      erb_reference,
      erb_status.present? ? erb_status.name : "",
      formatted_date(erb_submitted),
      formatted_date(erb_approved),
      formatted_date(erb_approval_expiry),
      formatted_date(local_erb_submitted),
      formatted_date(local_erb_approved),
      collaborators.map(&:name).to_sentence,
      study_notes.count,
      documents.count,
      publications.count,
      disseminations.count,
      study_impacts.count
    ]
  end

  # Return a date field formatted in a specified way, dealing with possible
  # nils. Hmm, this is more of a presentational concern...
  def formatted_date(value)
    return "" if value.blank?
    value.to_formatted_s(:medium_ordinal)
  end

  # Is this study archived?
  # Things get automatically archived after they've been completed for more
  # than a year
  def archived?
    return false if completed.nil? || study_stage != "completion"
    completed < Study.archive_date
  end

  # Does this study need flagging to the PI/RM for closer attention?
  def flagged?
    delayed_completing? || \
      erb_approval_expiring? || \
      erb_response_overdue? || \
      delivery_delayed?
  end

  # Is the study delayed in completing?
  def delayed_completing?
    return false if expected_completion_date.blank? || completed.present?
    expected_completion_date < Time.zone.today
  end

  # Is the study's ERB approval going to expire soon?
  def erb_approval_expiring?
    return false unless delivery? && erb_approval_expiry.present?
    erb_approval_expiry < Study.erb_approval_expiry_warning_at
  end

  # Is the ERB response overdue for this study?
  def erb_response_overdue?
    submitted = ErbStatus.submitted_status
    return false unless erb_status == submitted && erb_submitted.present?
    erb_submitted < Study.erb_response_overdue_at
  end

  # Exactly how delayed is this study's delivery?
  # Used to know whether to highlight the delay as "minor" or "major"
  def delivery_delayed_status
    if delivery_delayed?
      if latest_delivery_update.majorly_delayed?
        return "major"
      else
        return "minor"
      end
    else
      # Just in case we're called on a non-delayed study
      return "fine"
    end
  end

  # Exactly how bad is whatever we're flagging this study for?
  # (see #flagged? for what constitutes being flagged).
  def flagged_status
    if flagged?
      if delivery_delayed?
        return delivery_delayed_status
      else
        return "major"
      end
    else
      # Just in case we're called on a non-flagged study
      return "fine"
    end
  end

  def other_study_type_is_set_when_study_type_is_other
    if study_type == StudyType.other_study_type && other_study_type.blank?
      message = "You must describe the study type if you choose " \
                "\"#{StudyType::OTHER_STUDY_TYPE_NAME}\""
      errors.add(:other_study_type, message)
    end
  end

  # Override the country_codes setter to store an array of codes as a
  # comma-separated string in the db.
  def country_codes=(codes)
    self[:country_codes] = codes.reject(&:empty?).uniq.join(",")
  end

  # Override the country_codes getter to expand the comma-separated country
  # codes string from the db into an array.
  def country_codes
    if self[:country_codes].present?
      self[:country_codes].split(",")
    else
      []
    end
  end

  # Helper method to return a list of ISO3166::Country objects for this
  # study's country codes.
  def countries
    return if country_codes.empty?
    countries = []
    country_codes.each do |code|
      country = ISO3166::Country.new(code)
      unless country.nil?
        countries << country
      end
    end
    return countries unless countries.empty?
  end

  # Helper method to return a nice sentence with all of the countries names in
  def country_names
    return if countries.blank?
    countries.to_sentence
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
        recipient = nil
        if %w(principal_investigator_id research_manager_id).include?(attr_name)
          # Track the new owner/manager if it's changing
          # It might be changing to nil though, hence find_by_id not find
          recipient = User.find_by_id(after)
        end
        related_content = nil
        if attr_name == "erb_status_id"
          related_content = ErbStatus.find_by_id(after)
        end
        create_activity key, parameters: params,
                             owner: owner,
                             recipient: recipient,
                             related_content: related_content
      end
    end
  end

  def study_stage_label
    if archived?
      STUDY_STAGE_LABELS[:archived]
    else
      STUDY_STAGE_LABELS[study_stage.to_sym]
    end
  end

  def study_stage_description
    if archived?
      STUDY_STAGE_DESCRIPTIONS[:archived]
    else
      STUDY_STAGE_DESCRIPTIONS[study_stage.to_sym]
    end
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

  # Return a set of dates for important stage changes in the life of this study
  def stage_change_dates
    # rubocop:disable Style/MultilineOperationIndentation
    stage_changes = activities.where(key: "study.study_stage_changed").
                               order(created_at: :desc)
    # rubocop:enable Style/MultilineOperationIndentation
    dates = {
      protocol_change: nil,
      delivery_change: nil,
      completion_change: nil,
      withdrawn_change: nil
    }

    stage_changes.each do |activity|
      after = activity.parameters[:after]
      if after == "withdrawn_postponed" && dates[:withdrawn_change].blank?
        dates[:withdrawn_change] = activity.created_at
      elsif after == "completion" && dates[:completion_change].blank?
        dates[:completion_change] = activity.created_at
      elsif after == "delivery" && dates[:delivery_change].blank?
        dates[:delivery_change] = activity.created_at
      elsif after == "protocol_erb" && dates[:protocol_change].blank?
        dates[:protocol_change] = activity.created_at
      end
    end

    dates
  end

  # Has the title ever changed for this study?
  def title_changed?
    activities.where(key: "study.title_changed").exists?
  end

  # What was the original title (if the title hasn't changed, this just
  # returns the current title)
  def original_title
    change = activities.find_by(key: "study.title_changed")
    return change.parameters[:before] if change.present?
    title
  end

  def study_topic_names
    unless study_topics.empty?
      study_topics.order(:name).map(&:name).to_sentence
    end
  end

  # Is the study at a stage where we need to have an erb_status selected?
  def erb_status_needed?
    protocol_needed && !(concept? || withdrawn_postponed?)
  end

  # Can the supplied user manage this study?
  # e.g. change the study stage or invite people to edit it
  def user_can_manage?(user)
    return false if user.blank?
    user.is_admin || research_manager == user || principal_investigator == user
  end

  # Return the url to the most recent Protocol document
  def protocol_url
    protocol_doc_type = DocumentType.find_by_name("Protocol")
    # rubocop:disable Style/MultilineOperationIndentation
    protocol_doc = documents.where(document_type: protocol_doc_type).
                             order(created_at: :desc).
                             first
    # rubocop:enable Style/MultilineOperationIndentation
    unless protocol_doc.blank?
      return Rails.application.routes.url_helpers.document_url(protocol_doc)
    end
  end

  # Return the most recent delivery update
  def latest_delivery_update
    delivery_updates.order(created_at: :desc).first
  end

  def outstanding_delivery_update_invites
    delivery_update_invites.where("delivery_update_id IS NULL")
  end

  def outstanding_delivery_update_invites_for_user(user)
    outstanding_delivery_update_invites.where(invited_user: user.id)
  end

  def save_delivery_delayed
    if latest_delivery_update.present?
      self.delivery_delayed = latest_delivery_update.delayed?
    else
      self.delivery_delayed = false
    end
    save!
  end
end
