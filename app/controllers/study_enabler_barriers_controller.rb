class StudyEnablerBarriersController < ApplicationController
  include CreatingMultipleStudyResources

  def create_multiple
    @study = Study.find(params[:study_id])
    # The study enabler barrier form allows you to create multiple
    # enablers/barriers via multiple text areas. However, we don't have any
    # way of knowing whether someone actually wanted to select
    @study_enabler_barriers = create_multiple_resources(
      @study,
      StudyEnablerBarrier,
      study_enabler_barrier_params,
      :enabler_barrier_id,
      :description)

    if @study_enabler_barriers.empty?
      # Empty form submitted
      @study_enabler_barriers_errors = true
      flash[:alert] = "Sorry, you have to select at least one type of " \
                      "enabler/barrier"
      return render "studies/show"
    elsif @study_enabler_barriers.values.any?(&:invalid?)
      @study_enabler_barriers_errors = true
      flash[:alert] = "Sorry, looks like we're missing something, can you " \
                      "double check?"
      return render "studies/show"
    end
    # All good!
    message = "#{@study_enabler_barriers.count} " \
              "#{'Enabler/Barrier'.pluralize(@study_enabler_barriers.count)}" \
              " created successfully"
    redirect_to @study, notice: message
  end

  private

  def study_enabler_barrier_params
    allowed_ids = EnablerBarrier.all.map { |it| it.id.to_s }
    params.require(:study_enabler_barrier).
      permit(enabler_barrier_ids: allowed_ids, descriptions: allowed_ids)
  end
end
