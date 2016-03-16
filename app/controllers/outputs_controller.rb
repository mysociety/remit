class OutputsController < ApplicationController
  include CreatingMultipleStudyResources
  include InvitingUsers

  before_action :set_study_from_study_id, only: [:new, :create]
  before_action :check_user_can_contribute_to_study, only: [:new, :create]

  ALLOWED_RESOURCE_TYPES = %w(study_impact dissemination publication).freeze

  def new
  end

  def create
    resource_type = params[:output_type]
    if resource_type.blank?
      flash.now[:alert] = "Sorry, you have to select an output type."
      return render "new"
    end
    if ALLOWED_RESOURCE_TYPES.include? resource_type
      send("create_#{resource_type}")
    else
      raise ActionController::RoutingError.new("Not Found")
    end
  end

  private

  def create_study_impact
    @study_impacts = create_multiple_resources(
      @study,
      current_user,
      StudyImpact,
      study_impact_params,
      :impact_type_id,
      :description)

    if @study_impacts.empty?
      # Empty form submitted
      @study_impacts_errors = true
      flash.now[:alert] = "Sorry, you have to select at least " \
                          "one type of impact"
    elsif @study_impacts.values.any?(&:invalid?)
      @study_impacts_errors = true
      flash.now[:alert] = "Sorry, looks like we're missing something, can " \
                          "you double check?"
    else
      # All good!
      flash[:notice] = "#{@study_impacts.count} " \
                       "#{'Impact'.pluralize(@study_impacts.count)} created " \
                       "successfully"
    end
    render "new"
  end

  def study_impact_params
    allowed_ids = ImpactType.all.map { |it| it.id.to_s }
    params.require(:study_impact).permit(impact_type_ids: allowed_ids,
                                         descriptions: allowed_ids)
  end

  def create_dissemination
    @dissemination = Dissemination.new(dissemination_params)
    @dissemination.study = @study
    @dissemination.user = current_user
    if @dissemination.save
      flash[:notice] = "Dissemination created successfully"
    else
      flash.now[:alert] = "Sorry, looks like we're missing something, can " \
                          "you double check?"
    end
    render "new"
  end

  def dissemination_params
    params.require(:dissemination).permit(:dissemination_category_id,
                                          :details, :fed_back_to_field,
                                          :other_dissemination_category)
  end

  def create_publication
    @publication = Publication.new(publication_params)
    @publication.study = @study
    @publication.user = current_user
    if @publication.save
      flash[:notice] = "Publication created successfully"
    else
      flash.now[:alert] = "Sorry, looks like we're missing something, can " \
                          "you double check?"
    end
    render "new"
  end

  def publication_params
    params.require(:publication).permit(:doi_number, :article_title,
                                        :book_or_journal_title,
                                        :publication_year, :lead_author)
  end

  def set_invited_user
    @invited_user = User.find_by_invite_token(@invite_token)
  end

  def set_invite
    @invite = StudyInvite.where(study: @study, invited_user: @invited_user)
  end
end
