ActiveAdmin.register StudyImpact do
  permit_params :impact_type_id, :study_id, :description, :user_id

  menu priority: 4

  filter :study
  filter :user
  filter :impact_type_id
  filter :created_at

  index do
    selectable_column
    column :impact_type
    column("Study Ref") { |instance| instance.study.reference_number }
    column("Study Title") { |instance| instance.study.title }
    column :description
    column :user
    column :created_at
    actions
  end

  csv do
    # Active Admin doesn't do as much auto-field seleting magic for CSVs
    # so we have to be explicit about what we want from the foreign keys
    column("Impact Type") { |i| i.impact_type.name }
    column("Study Ref") { |instance| instance.study.reference_number }
    column("Study Title") { |instance| instance.study.title }
    column :description
    column("User") { |instance| instance.user.name }
    column :created_at
  end
end
