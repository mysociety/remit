class ApplicationController < ActionController::Base
  # Use PublicActivity's StoreController so that we can default to all
  # activities belonging to the current_user
  include PublicActivity::StoreController

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Configure Devise's permitted params
  before_action :configure_permitted_parameters, if: :devise_controller?

  add_flash_types :success

  # Authenticate the currently logged in user for access to the the admin
  # site. ActiveAdmin calls this
  # (it's set in config/initializers/active_admin.rb) from a before_filter to
  # check if people should be accessing the admin.
  def authenticate_admin_user!
    if !current_user
      redirect_to new_user_session_path
    elsif !current_user.is_admin
      forbidden
    end
  end

  # Redirect admins to the admin dashboard
  def after_sign_in_path_for(resource)
    stored_location_for(resource) ||
      if resource.is_a?(User) && resource.is_admin
        admin_dashboard_path
      elsif resource.is_a?(User) && resource.studies.count > 0
        user_studies_path(resource)
      else
        root_path
      end
  end

  # Check that the current user is allowed to manage a study
  # Note: expects you to set a study in @study before you call this
  def check_user_can_manage_study
    if current_user.nil?
      return redirect_to new_user_session_path
    end
    unless @study.user_can_manage?(current_user)
      forbidden
    end
  end

  # Set an @study from the study_id param
  def set_study_from_study_id
    @study = Study.find(params[:study_id])
  end

  protected

  def respond_with_studies_csv(studies)
    send_data studies.to_csv, filename: "studies-#{Time.zone.today}.csv"
  end

  # Helper to return and render a 403
  def forbidden
    render(file: File.join(Rails.root, "public/403"),
           status: 403,
           formats: [:html],
           layout: false)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :name
    devise_parameter_sanitizer.for(:account_update) << :name
  end
end
