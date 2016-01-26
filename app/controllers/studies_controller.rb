class StudiesController < ApplicationController
  def show
    @study = Study.find(params[:id])
    @document = Document.new
  end
end
