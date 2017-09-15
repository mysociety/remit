ActiveAdmin.register Study do
  permit_params :study_stage, :title, :reference_number, :operating_center, :generated_reference_id, :study_type_id,
                :study_setting_id, :research_team, :concept_paper_date,
                :protocol_needed, :pre_approved_protocol, :erb_status_id,
                :erb_submitted, :erb_approved,
                :erb_reference, :erb_approval_expiry, :local_erb_submitted,
                :local_erb_approved, :exemption_approved_by,
                :amendments_sent_to_erb,
                :completed, :other_study_type, :principal_investigator_id,
                :research_manager_id, :expected_completion_date, :hidden,
                country_codes: [], study_topic_ids: [],
                collaborator_ids: [],
                collaborator_attributes: [:id, :name, :description]

  menu priority: 1

  filter(
    :study_stage,
    as: :select,
    collection: Study::STUDY_STAGE_OPTIONS.dup.except("Archived"),
    label: "Study Stage")
  filter :study_topics
  filter :study_type
  filter(
    :by_operating_center_in,
    label: "Operating Center",
    as: :select,
    collection: Study::OPERATING_CENTER.invert
  )
  filter :erb_status
  filter :principal_investigator
  filter :research_manager
  filter :concept_paper_date
  filter :collaborators
  filter :hidden

  scope :all, default: true
  scope "Active", :active
  scope "Archived", :archived
  scope "ERB Overdue", :erb_approval_expiring
  scope "ERB Expiring", :erb_approval_expiring
  scope "Delivery Delayed", :delivery_delayed
  scope "Delayed Completing", :delayed_completing

  # We use a custom form partial so that we can include some helpful info
  # for the reference number auto-generation
  form partial: "form"

  index do
    selectable_column
    column "Reference", :reference_number, link: true
    column :title
    column "Stage", :study_stage
    column "Topics", :study_topic_names
    column "Type", :study_type
    column "PI", :principal_investigator
    column :concept_paper_date
    actions
  end
end
