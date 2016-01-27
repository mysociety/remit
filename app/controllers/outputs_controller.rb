class OutputsController < ApplicationController
  ALLOWED_RESOURCE_TYPES = %w(study_impact dissemination publication).freeze

  def create
    @study = Study.find(params[:study_id])
    resource_type = params[:output_type]
    if resource_type.blank?
      flash[:alert] = "Sorry, you have to select an output type."
      return render "studies/show"
    end
    if ALLOWED_RESOURCE_TYPES.include? resource_type
      send("create_#{resource_type}")
    else
      raise ActionController::RoutingError.new("Not Found")
    end
  end

  private

  def create_study_impact
    # The study impact form allows you to create multiple impacts via a
    # multiple select checkbox, so we take an all-or-nothing approach to
    # creating them
    @study_impacts = {}
    StudyImpact.transaction do
      impact_type_ids = study_impact_params[:impact_type_ids]
      descriptions = study_impact_params[:descriptions]
      impact_type_ids.values.each do |impact_type_id|
        study_impact = StudyImpact.new(
          impact_type_id: impact_type_id,
          description: descriptions[impact_type_id])
        study_impact.study = @study
        @study_impacts[impact_type_id.to_i] = study_impact
        # We call this and ignore the output for now, so that we can get
        # errors for each impact in one go and then decide whether to rollback
        # and show the errors, or continue
        study_impact.save
      end
      if @study_impacts.empty?
        # Empty form submitted
        flash[:alert] = "Sorry, you to select at least one type of impact"
        return redirect_to @study
      elsif @study_impacts.values.any?(&:invalid?)
        # One of the impacts (at least) had an error, rollback and show it
        raise ActiveRecord::Rollback
      else
        # All good!
        message = "#{@study_impacts.count} " \
                  "#{'Impact'.pluralize(@study_impacts.count)} created " \
                  "successfully"
        return redirect_to @study, notice: message
      end
    end
    # We only get here if the transaction rolled back, so everything wasn't
    # saved
    @study_impacts_errors = true
    flash[:alert] = "Sorry, looks like we're missing something, can you " \
                    "double check?"
    render "studies/show"
  end

  def study_impact_params
    allowed_ids = ImpactType.all.map { |it| it.id.to_s }
    params.require(:study_impact).permit(impact_type_ids: allowed_ids,
                                         descriptions: allowed_ids)
  end

  def create_dissemination
    @dissemination = Dissemination.new(dissemination_params)
    @dissemination.study = @study
    if @dissemination.save
      redirect_to @study, notice: "Dissemination created successfully"
    else
      flash[:alert] = "Sorry, looks like we're missing something, can you " \
                    "double check?"
      render "studies/show"
    end
  end

  def dissemination_params
    params.require(:dissemination).permit(:dissemination_category_id,
                                          :details, :fed_back_to_field,
                                          :other_dissemination_category)
  end

  def create_publication
    @publication = Publication.new(publication_params)
    @publication.study = @study
    if @publication.save
      redirect_to @study, notice: "Publication created successfully"
    else
      flash[:alert] = "Sorry, looks like we're missing something, can you " \
                    "double check?"
      render "studies/show"
    end
  end

  def publication_params
    params.require(:publication).permit(:doi_number, :article_title,
                                        :book_or_journal_title,
                                        :publication_year, :lead_author)
  end
end
