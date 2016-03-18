ActiveAdmin.register DeliveryUpdateInvite do
  permit_params :study_id, :invited_user_id, :inviting_user_id,
                :delivery_update_id

  menu priority: 3

  filter :study
  filter :invited_user
  filter :inviting_user
  filter :created

  index do
    selectable_column
    column :invited_user
    column :study
    column :inviting_user
    column :created_at
    actions
  end
end
