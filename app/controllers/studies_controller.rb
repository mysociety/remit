class StudiesController < ApplicationController
  include ListingStudies

  before_action :set_and_authenticate_user, only: :index
  before_action :set_study_from_study_id, only: [:progress_to_delivery,
                                                 :progress_to_completion]
  before_action :check_user_can_manage_study, only: [:progress_to_delivery,
                                                     :progress_to_completion]

  def index
    page = params[:page]
    # rubocop:disable Style/MultilineOperationIndentation
    @studies = get_filtered_studies.
                 where(principal_investigator_id: @user.id).
                 send(@study_scope).
                 order(@ordering).
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
