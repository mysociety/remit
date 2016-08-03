class OutputsController < ApplicationController
  include CreatingMultipleStudyResources
  include InvitingUsers
  # For truncate
  include ActionView::Helpers::TextHelper

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
      set_existing_outputs
      render "new"
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
      flash.now[:success] = "#{@study_impacts.count} " \
                           "#{'Impact'.pluralize(@study_impacts.count)} " \
                           "added successfully"
      # We're rendering the form for people to create more impacts, so
      # we clear out @study_impacts to avoid duplicate data
      @study_impacts = {}
    end
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
      flash.now[:success] = "#{@dissemination.dissemination_category.name} " \
                           "Dissemination added successfully"
      # We're rendering the form for people to create another dissemination,
      # so we clear out @disseminatin to avoid duplicate data
      @dissemination = Dissemination.new
    else
      flash.now[:alert] = "Sorry, looks like we're missing something, can " \
                          "you double check?"
    end
  end

  def dissemination_params
    params.require(:dissemination).permit(:dissemination_category_id,
                                          :details,
                                          :other_dissemination_category)
  end

  def create_publication
    @publication = Publication.new(publication_params)
    @publication.study = @study
    @publication.user = current_user
    if @publication.save
      title = truncate(@publication.article_title, length: 50)
      flash.now[:success] = "Publication \"#{title}\" added successfully"
      # We're rendering the form for people to create another publication, so
      # we clear out @publication to avoid duplicate data
      @publication = Publication.new
    else
      flash.now[:alert] = "Sorry, looks like we're missing something, can " \
                          "you double check?"
    end
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

  def set_existing_outputs
    @users_impacts = current_user.study_impacts.where(study: @study)
    @users_disseminations = current_user.disseminations.where(study: @study)
    @users_publications = current_user.publications.where(study: @study)
    @users_outputs = @users_impacts + \
                     @users_disseminations + \
                     @users_publications
  end
end
