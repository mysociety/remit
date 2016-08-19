ActiveAdmin.register Dissemination do
  permit_params :dissemination_category_id, :study_id, :details, :user_id,
                :other_dissemination_category

  menu priority: 3

  filter :study
  filter :user
  filter :created_at
  filter :dissemination_category

  index do
    selectable_column
    column :dissemination_category
    column("Study Ref") { |i| i.study.reference_number }
    column("Study Title") { |i| i.study.title }
    column :other_dissemination_category
    column :user
    column :created_at
    actions
  end

  csv do
    # Active Admin doesn't do as much auto-field seleting magic for CSVs
    # so we have to be explicit about what we want from the foreign keys
    column("Dissemination Category") { |i| i.dissemination_category.name }
    column("Study Ref") { |i| i.study.reference_number }
    column("Study Title") { |i| i.study.title }
    column :other_dissemination_category
    column :details
    column("User") { |i| i.user.name }
    column :created_at
  end
end
