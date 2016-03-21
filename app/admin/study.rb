ActiveAdmin.register Study do
  permit_params :study_stage, :title, :reference_number, :study_type_id,
                :study_setting_id, :research_team, :concept_paper_date,
                :protocol_needed, :pre_approved_protocol, :erb_status_id,
                :erb_submitted, :erb_approved,
                :erb_reference, :erb_approval_expiry, :local_erb_submitted,
                :local_erb_approved, :completed, :local_collaborators,
                :international_collaborators, :other_study_type,
                :principal_investigator_id, :research_manager_id,
                :expected_completion_date, :hidden,
                country_codes: [], study_topic_ids: []

  menu priority: 1

  filter :study_stage
  filter :study_topics
  filter :study_type
  filter :erb_status
  filter :principal_investigator
  filter :research_manager
  filter :concept_paper_date

  scope :all, default: true
  Study::STUDY_STAGE_LABELS.each do |stage, label|
    scope label, stage
  end

  form do |f|
    f.inputs "Details" do
      f.input :title, as: :string
      f.input :reference_number, as: :string
      f.input :study_stage, as: :select,
                            collection: Study::STUDY_STAGE_OPTIONS
      f.input :study_topics, input_html: { size: 10 }
      f.input :study_type
      f.input :other_study_type, as: :string
      f.input :study_setting
      f.input(
        :country_codes,
        label: "Countries",
        as: :country,
        include_blank: true,
        priority_countries: %w(BD CD ET HT NG SS UZ ZW),
        input_html: { multiple: true, size: 10 })
      f.input :principal_investigator
      f.input :research_manager
      f.input :research_team
      f.input :concept_paper_date
      f.input :expected_completion_date
      f.input :protocol_needed
      f.input :pre_approved_protocol
      f.input :erb_status
      f.input :erb_reference, as: :string
      f.input :erb_submitted
      f.input :erb_approved
      f.input :local_erb_submitted
      f.input :local_erb_approved
      f.input :erb_approval_expiry
      f.input :local_collaborators
      f.input :international_collaborators
      f.input :completed
      f.input :hidden, hint: "Check this box to hide the study from people " \
                             "who aren't logged in"
    end
    f.actions
  end

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
