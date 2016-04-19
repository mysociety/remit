ActiveAdmin.register Document do
  permit_params :document_type_id, :study_id, :document, :user_id

  menu priority: 3

  filter :study
  filter :user
  filter :created_at
  filter :document_type

  form do |f|
    f.semantic_errors
    f.inputs "Details" do
      f.input :document_type
      f.input :study
      f.input :user
      f.input :document, as: :file
    end
    f.actions
  end

  index do
    selectable_column
    column :document_file_name
    column :document_type
    column :study
    column :user
    column :created_at
    actions
  end
end
