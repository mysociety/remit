ActiveAdmin.register DeliveryUpdateInvite do
  permit_params :study_id, :invited_user_id, :inviting_user_id,
                :delivery_update_id

  menu parent: "Delivery updates"

  filter :study
  filter :invited_user
  filter :inviting_user
  filter :created

  index do
    selectable_column
    column :invited_user
    column "Study Ref" do |instance|
      instance.study.reference_number
    end
    column "Study Title" do |instance|
      instance.study.title
    end
    column :inviting_user
    column :created_at
    actions
  end
end
