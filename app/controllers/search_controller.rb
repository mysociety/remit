class SearchController < ApplicationController
  include ListingStudies

  def index
    studies = Study.send(@study_scope)

    unless params[:pi].blank?
      studies = studies.joins(:principal_investigator).where('lower(users.name) = ?', params[:pi].downcase)
    end

    # rubocop:disable Style/MultilineOperationIndentation
    @studies = studies.
                 order(updated_at: :desc).
                 page(params[:page]).
                 per(10)
    # rubocop:enable Style/MultilineOperationIndentation
  end
end
