class HomeController < ApplicationController
  include ListingStudies

  def index
    @studies = get_search_results(get_filtered_studies).order(@ordering)
    respond_to do |format|
      format.html do
        @studies = @studies.page(params[:page]).per(10)
        @show_quick_filters = current_user && current_user.is_admin
      end
      format.csv { respond_with_studies_csv(@studies) }
    end
  end
end
