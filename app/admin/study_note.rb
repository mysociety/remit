ActiveAdmin.register StudyNote do
  permit_params :notes, :study_id, :user_id

  menu priority: 3

  filter :study
  filter :user
  filter :notes
  filter :created_at

  index do
    selectable_column
    column :notes
    column :study
    column :user
    column :created_at
    actions
  end
end
