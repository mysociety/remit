class SearchController < ApplicationController
  include ListingStudies

  def index
    @studies = get_search_results.order(@ordering)
    respond_to do |format|
      format.html do
        @studies = @studies.page(params[:page]).per(10)
        @show_quick_filters = current_user && current_user.is_admin
      end
      format.csv { respond_with_studies_csv(@studies) }
    end
  end

  protected

  def get_search_results
    studies = get_filtered_studies

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
