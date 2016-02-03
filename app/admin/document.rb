ActiveAdmin.register Document do
  permit_params :document_type_id, :study_id, :document

  menu priority: 3

  filter :study
  filter :created_at
  filter :document_type

  form do |f|
    f.semantic_errors
    f.inputs "Details" do
      f.input :document_type
      f.input :study
      f.input :document, as: :file
    end
    f.actions
  end

  index do
    selectable_column
    column :study
    column :document_type
    column :document_file_name
    column :created_at
    column :updated_at
    actions
  end
end
