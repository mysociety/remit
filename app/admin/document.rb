ActiveAdmin.register Document do
  permit_params :document_type_id, :study_id, :document, :user_id,
                :description

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
      f.input :description
    end
    f.actions
  end

  index do
    selectable_column
    column :document_file_name
    column :description
    column :document_type
    column "Study Ref" do |instance|
      instance.study.reference_number
    end
    column "Study Title" do |instance|
      instance.study.title
    end
    column :user
    column :created_at
    actions
  end
end
