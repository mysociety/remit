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
    @study_topics = StudyTopic.all.order(name: :asc)
    @countries = {}
    Study.select(:country_codes).distinct.map(&:country_codes).flatten.each do |codes|
      codes.split(",").each do |code|
        @countries[ISO3166::Country.new(code).name] = code
      end
    end

    # These indicate the current filter in use, if any, and will be
    # set appropriately by get_filtered_studies
    @study_type = nil
    @study_stage = nil
    @study_topic = nil
    @study_setting = nil
    @country = nil
  end

  def get_filtered_studies
    studies = Study.send(@study_scope)

    unless params[:pi].blank?
      studies = studies.joins(:principal_investigator).where('lower("users"."name") = ?', params[:pi].downcase)
    end

    unless params[:study_type].blank?
      studies = studies.joins(:study_type).where('lower("study_types"."name") = ?', params[:study_type].downcase)
      @study_type = params[:study_type].downcase
    end

    unless params[:study_topic].blank?
      studies = studies.joins(:study_topics).where('lower("study_topics"."name") = ?', params[:study_topic].downcase)
      @study_topic = params[:study_topic].downcase
    end

    unless params[:country].blank? || ISO3166::Country.new(params[:country]).nil?
      studies = studies.in_country(params[:country])
      @country = params[:country]
    end

    unless params[:study_stage].blank?
      studies = studies.where(study_stage: params[:study_stage])
      @study_stage = params[:study_stage].downcase
    end

    studies
  end
end