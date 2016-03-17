ActiveAdmin.register DeliveryUpdateInvite do
  permit_params :study_id, :invited_user_id, :inviting_user_id,
                :delivery_update_id

  menu priority: 3

  filter :study
  filter :invited_user
  filter :inviting_user
  filter :created
end
