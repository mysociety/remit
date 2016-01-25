ActiveAdmin.register StudyNote do
  permit_params :notes, :study_id

  menu priority: 3

  filter :study
  filter :notes
  filter :created_at
end
