class StudiesController < ApplicationController
  include ListingStudies

  before_action :set_and_authenticate_user, only: :index
  before_action :set_study_from_study_id, only: [:progress_to_delivery,
                                                 :progress_to_completion]
  before_action :check_user_can_manage_study, only: [:progress_to_delivery,
                                                     :progress_to_completion]

  def index
    sql = <<-SQL
      principal_investigator_id = ? OR research_manager_id = ?
    SQL
    filtered_studies = get_filtered_studies.where(sql, @user.id, @user.id)
    @studies = get_search_results(filtered_studies).order(@ordering)
    respond_to do |format|
      format.html do
        @studies = @studies.page(params[:page]).per(10)
        @show_flagged = true
        if @user.is_admin || @user.research_manager_studies.any?
          @show_quick_filters = true
        end
        @show_delivery_updates = true
        render "home/index"
      end
      format.csv { respond_with_studies_csv(@studies) }
    end
  end

  def show
    if current_user
      if current_user.is_admin?
        @study = Study.find(params[:id])
      else
        @study = Study.visible_to_user(current_user).find(params[:id])
      end
    else
      @study = Study.visible.find(params[:id])
    end
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
    flash[:success] = "Study stage updated successfully"
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
    flash[:success] = "Study stage updated successfully"
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
