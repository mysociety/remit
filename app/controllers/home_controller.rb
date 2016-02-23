class HomeController < ApplicationController
  include ListingStudies

  def index
    @studies = get_filtered_studies.order(@ordering)
    respond_to do |format|
      format.html { @studies = @studies.page(params[:page]).per(10) }
      format.csv { respond_with_studies_csv(@studies) }
    end
  end
end
