class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Authenticate the currently logged in user for access to the the admin
  # site. ActiveAdmin calls this
  # (it's set in config/initializers/active_admin.rb) from a before_filter to
  # check if people should be accessing the admin.
  def authenticate_admin_user!
    if !current_user
      redirect_to new_user_session_path
    elsif !current_user.admin?
      render status: :forbidden,
             text: "Sorry, you don't have access to this page"
    end
  end

  # Redirect admins to the admin dashboard
  def after_sign_in_path_for(resource)
    stored_location_for(resource) ||
      if resource.is_a?(User) && resource.admin?
        admin_dashboard_path
      else
        root_path
      end
  end
end
