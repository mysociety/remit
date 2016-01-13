class StudiesController < ApplicationController
  def show
    @study = Study.find(params[:id])
  end
end
