class StudiesController < ApplicationController
  before_action :set_and_authenticate_user, only: :index

  def index
    page = params[:page]
    @studies = @user.studies.order(updated_at: :desc).page(page).per(10)
    @total_studies = @user.studies.count
    render "home/index"
  end

  def show
    @study = Study.find(params[:id])
    @document = Document.new
    @study_note = StudyNote.new
    @publication = Publication.new
    @dissemination = Dissemination.new
    @study_impacts = {}
  end

  protected

  def set_and_authenticate_user
    if current_user.nil?
      return redirect_to new_user_session_path
    end
    @user = User.find(params[:user_id])
    unless @user == current_user || current_user.is_admin
      forbidden
    end
  end
end
