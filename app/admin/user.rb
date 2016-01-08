ActiveAdmin.register User do
  permit_params :name, :email, :role, :msf_location_id, :external_location

  menu priority: 2

  filter :role, as: :select, collection: User.roles
  filter :msf_location
  filter :created_at

  index default: true do
    selectable_column
    column :name
    column :email
    column :msf_location
    column :external_location
    column :role
    column :created_at
    column :last_sign_in_at

    actions
  end

  form do |f|
    f.inputs "Edit User" do
      f.input :name
      f.input :msf_location
      f.input :external_location
      f.input :role, as: :select, collection: User.roles
    end
    f.actions
  end
end
