ActiveAdmin.register StudyInvite do
  permit_params :study_id, :inviting_user_id, :invited_user_id

  menu priority: 3

  filter :study
  filter :inviting_user
  filter :invited_user_id
  filter :created_at
end
