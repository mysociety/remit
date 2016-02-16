class StudiesController < ApplicationController
  include ListingStudies

  before_action :set_and_authenticate_user, only: :index
  before_action :set_study, only: [:progress_to_delivery,
                                   :progress_to_completion]
  before_action :check_user_can_manage_study, only: [:progress_to_delivery,
                                                     :progress_to_completion]

  def index
    page = params[:page]
    # rubocop:disable Style/MultilineOperationIndentation
    @studies = @user.studies.
                     send(@study_scope).
                     order(updated_at: :desc).
                     page(page).
                     per(10)
    # rubocop:enable Style/MultilineOperationIndentation
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

  def progress_to_delivery
    if @study.protocol_erb?
      @study.study_stage = "delivery"
      @study.save!
    end
    flash[:notice] = "Study stage updated successfully"
    redirect_to study_path(@study)
  rescue
    flash[:alert] = "Sorry, we couldn't update the study, please try again"
  end

  def progress_to_completion
    if @study.delivery?
      @study.study_stage = "completion"
      @study.completed = Time.zone.today
      @study.save!
    end
    flash[:notice] = "Study stage updated successfully"
    redirect_to study_path(@study)
  rescue
    flash[:alert] = "Sorry, we couldn't update the study, please try again"
  end

  protected

  def set_study
    @study = Study.find(params[:study_id])
  end

  def set_and_authenticate_user
    if current_user.nil?
      return redirect_to new_user_session_path
    end
    @user = User.find(params[:user_id])
    unless @user == current_user || current_user.is_admin
      forbidden
    end
  end

  def check_user_can_manage_study
    if current_user.nil?
      return redirect_to new_user_session_path
    end
    unless @study.user_can_manage?(current_user)
      forbidden
    end
  end
end
