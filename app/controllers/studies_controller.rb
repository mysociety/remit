class StudiesController < ApplicationController
  def show
    @study = Study.find(params[:id])
    @document = Document.new
    @study_note = StudyNote.new
  end
end
