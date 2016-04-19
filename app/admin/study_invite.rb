ActiveAdmin.register StudyInvite do
  permit_params :study_id, :inviting_user_id, :invited_user_id

  menu priority: 3

  filter :study
  filter :inviting_user
  filter :invited_user
  filter :created_at

  index do
    selectable_column
    column :invited_user
    column :study
    column :inviting_user
    column :created_at
    actions
  end
end
