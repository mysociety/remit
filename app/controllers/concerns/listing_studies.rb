module ListingStudies
  extend ActiveSupport::Concern

  included do
    before_action :set_include_archived, only: :index
    before_action :set_study_scope, only: :index
    before_action :set_filter_form_values, only: :index
  end

  def set_include_archived
    @include_archived = params[:include_archived] == "1"
  end

  def set_study_scope
    @study_scope = :not_archived_or_withdrawn
    if @include_archived
      @study_scope = :not_withdrawn
    end
  end

  def set_filter_form_values
    @study_types = StudyType.all.order(name: :asc)
  end

  def get_filtered_studies
    studies = Study.send(@study_scope)

    unless params[:pi].blank?
      studies = studies.joins(:principal_investigator).where('lower("users"."name") = ?', params[:pi].downcase)
    end

    unless params[:study_type].blank?
      studies = studies.joins(:study_type).where('lower("study_types"."name") = ?', params[:study_type].downcase)
    end

    studies
  end
end
