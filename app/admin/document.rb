ActiveAdmin.register Document do
  permit_params :document_type_id, :study_id

  menu priority: 3

  filter :study
  filter :created_at
  filter :document_type
end
