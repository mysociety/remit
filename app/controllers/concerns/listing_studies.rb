module ListingStudies
  extend ActiveSupport::Concern

  included do
    before_action :set_include_archived, only: :index
    before_action :set_study_scope, only: :index
    before_action :set_filter_form_values, only: :index
    before_action :set_ordering, only: :index
    before_action :set_flagged_studies_count, only: :index
  end

  def set_include_archived
    @include_archived = params[:include_archived] == "1"
  end

  def set_study_scope
    case params[:scope]
    when "delayed_completing"
      @study_scope = :delayed_completing
    when "erb_response_overdue"
      @study_scope = :erb_response_overdue
    when "erb_approval_expiring"
      @study_scope = :erb_approval_expiring
    else
      @study_scope = :not_archived_or_withdrawn
      if @include_archived
        @study_scope = :not_withdrawn
      end
    end
  end

  def set_filter_form_values
    @study_types = StudyType.all.order(name: :asc)
    @study_topics = StudyTopic.all.order(name: :asc)
    @countries = {}
    codes = Study.select(:country_codes).distinct.map(&:country_codes).flatten
    codes.each do |code_string|
      code_string.split(",").each do |code|
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

  def set_ordering
    case params[:order]
    when "updated"
      @ordering = { updated_at: :desc }
    when "created"
      @ordering = { created_at: :desc }
    else
      @ordering = { updated_at: :desc }
    end
  end

  def get_filtered_studies
    if current_user
      studies = Study.send(@study_scope)
    else
      studies = Study.visible.send(@study_scope)
    end

    unless params[:study_type].blank?
      study_type_sql = 'lower("study_types"."name") = ?'
      # rubocop:disable Style/MultilineOperationIndentation
      studies = studies.joins(:study_type).
                        where(study_type_sql, params[:study_type].downcase)
      # rubocop:enable Style/MultilineOperationIndentation
      @study_type = params[:study_type].downcase
    end

    unless params[:study_topic].blank?
      study_topic_sql = 'lower("study_topics"."name") = ?'
      # rubocop:disable Style/MultilineOperationIndentation
      studies = studies.joins(:study_topics).
                        where(study_topic_sql, params[:study_topic].downcase)
      # rubocop:enable Style/MultilineOperationIndentation
      @study_topic = params[:study_topic].downcase
    end

    unless params[:country].blank? ||
           ISO3166::Country.new(params[:country]).nil?
      studies = studies.in_country(params[:country])
      @country = params[:country]
    end

    unless params[:study_stage].blank?
      studies = studies.where(study_stage: params[:study_stage])
      @study_stage = params[:study_stage].downcase
    end

    studies
  end

  def set_flagged_studies_count
    unless current_user.blank?
      @flagged_studies_count = current_user.studies.flagged.count
    end
  end
end
