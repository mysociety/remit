class SearchController < ApplicationController
  include ListingStudies

  def index
    # rubocop:disable Style/MultilineOperationIndentation
    @studies = get_search_results.
                 order(updated_at: :desc).
                 page(params[:page]).
                 per(10)
    # rubocop:enable Style/MultilineOperationIndentation
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

      # Match PI name
      queries << studies.joins(:principal_investigator).where(
                  'lower("users"."name") LIKE ?',
                  "%#{@q.downcase}%"
                ).to_sql

      # Match study topic name
      queries << studies.joins(:study_topics).where(
                  'lower("study_topics"."name") LIKE ?',
                  "%#{@q.downcase}%"
                ).to_sql

      # Match study title
      queries << studies.where(
                  'lower("title") LIKE ?',
                  "%#{@q.downcase}%"
                ).to_sql

      # Match country name
      country = ISO3166::Country.find_country_by_name(@q)
      unless country.nil?
        queries << studies.in_country(country.alpha2).to_sql
      end

      sql = "(#{queries.join(' UNION ')}) AS studies"
      studies = Study.from(sql)
    end

    studies
  end
end
