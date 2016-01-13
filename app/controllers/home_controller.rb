class HomeController < ApplicationController
  def index
    @studies = Study.order(:updated_at).page params[:page]
  end
end
