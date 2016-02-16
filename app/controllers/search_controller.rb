class SearchController < ApplicationController
  include ListingStudies

  def index
    # rubocop:disable Style/MultilineOperationIndentation
    @studies = Study.send(@study_scope).
                     order(updated_at: :desc).
                     page(params[:page]).
                     per(10)
    # rubocop:enable Style/MultilineOperationIndentation
  end
end
