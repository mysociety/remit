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

    # These indicate the current filter(s) in use, if any, and will be
    # set appropriately by get_filtered_studies
    @selected_study_types = []
    @selected_study_stages = []
    @selected_study_topics = []
    @selected_countries = []
  end

  def set_ordering
    case params[:order]
    when "updated"
      @ordering = { updated_at: :desc }
      @selected_ordering = "updated"
    when "created"
      @ordering = { created_at: :desc }
      @selected_ordering = "created"
    else
      @ordering = { created_at: :desc }
      @selected_ordering = "created"
    end
  end

  def get_filtered_studies
    if current_user
      studies = Study.send(@study_scope)
    else
      studies = Study.visible.send(@study_scope)
    end

    unless params[:study_type].blank?
      downcased_study_types = params[:study_type].map(&:downcase)
      study_type_sql = 'lower("study_types"."name") IN (?)'
      # rubocop:disable Style/MultilineOperationIndentation
      studies = studies.joins(:study_type).
                        where(study_type_sql, downcased_study_types)
      # rubocop:enable Style/MultilineOperationIndentation
      @selected_study_types = downcased_study_types
    end

    unless params[:study_topic].blank?
      downcased_study_topics = params[:study_topic].map(&:downcase)
      study_topic_sql = 'lower("study_topics"."name") IN (?)'
      # rubocop:disable Style/MultilineOperationIndentation
      studies = studies.joins(:study_topics).
                        where(study_topic_sql, downcased_study_topics)
      # rubocop:enable Style/MultilineOperationIndentation
      @selected_study_topics = downcased_study_topics
    end

    unless params[:country].blank?
      valid_countries = params[:country].reject do |c|
        ISO3166::Country.new(c).nil?
      end
      unless valid_countries.blank?
        studies = studies.in_countries(valid_countries)
        @selected_countries = valid_countries
      end
    end

    unless params[:study_stage].blank?
      studies = studies.where(study_stage: params[:study_stage])
      @selected_study_stages = params[:study_stage].map(&:downcase)
    end

    studies
  end

  def set_flagged_studies_count
    unless current_user.blank?
      @flagged_studies_count = current_user.studies.flagged.count
    end
  end

  def get_search_results(studies)
    @q = params[:q]
    unless @q.blank?
      # We want to find Studies that match the query on many fields, so build a
      # query using UNION. Building the list of results as an array wouldn't be
      # suitable because we need an ActiveRecord_Relation for pagination,
      # ordering etc.
      queries = []

      q_param = "%#{@q.downcase}%"

      # Match PI name
      pi_sql = 'lower("users"."name") LIKE ?'
      # rubocop:disable Style/MultilineOperationIndentation
      queries << studies.joins(:principal_investigator).
                         where(pi_sql, q_param).
                         to_sql
      # rubocop:enable Style/MultilineOperationIndentation

      # Match study topic name
      topic_sql = 'lower("study_topics"."name") LIKE ?'
      queries << studies.joins(:study_topics).where(topic_sql, q_param).to_sql

      # Match study title
      queries << studies.where('lower("title") LIKE ?', q_param).to_sql

      # Match country name
      country = ISO3166::Country.find_country_by_name(@q)
      unless country.nil?
        queries << studies.in_country(country.alpha2).to_sql
      end

      # Match reference number. We do this exactly because it's quite short
      # and so a LIKE could bring up lots of false positives
      reference_number_sql = 'lower("reference_number") = ?'
      queries << studies.where(reference_number_sql, @q.downcase).to_sql

      sql = "(#{queries.join(' UNION ')}) AS studies"
      studies = Study.from(sql)
    end

    studies
  end
end
