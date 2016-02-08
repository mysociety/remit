class HomeController < ApplicationController
  def index
    @studies = Study.order(updated_at: :desc).page(params[:page]).per(10)
    @total_studies = Study.count
  end
end
