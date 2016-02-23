ActiveAdmin.register User do
  permit_params :name, :email, :is_admin, :msf_location_id, :external_location,
                :password, :password_confirmation, :approved

  menu priority: 2

  filter :is_admin
  filter :approved
  filter :msf_location
  filter :created_at

  index default: true do
    selectable_column
    column :name
    column :email
    column :msf_location
    column :external_location
    column :is_admin
    column :created_at
    column :last_sign_in_at

    actions
  end

  form do |f|
    f.inputs "Details" do
      f.input :name, as: :string
      f.input :email, as: :string
      f.input :msf_location
      f.input :external_location, as: :string
      f.input :password
      f.input :password_confirmation
      f.input :is_admin
      f.input :approved
    end
    f.actions
  end

  # Override the update to ignore empty passwords (so that we can change
  # other things without having to set a password every time).
  controller do
    def update
      if params[:user][:password].blank? && \
         params[:user][:password_confirmation].blank?
        params[:user].delete("password")
        params[:user].delete("password_confirmation")
      end
      super
    end
  end
end
