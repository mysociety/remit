class StudiesController < ApplicationController
  def show
    @study = Study.find(params[:id])
    @document = Document.new
    @study_note = StudyNote.new
    @publication = Publication.new
    @dissemination = Dissemination.new
    @study_impacts = {}
  end
end
