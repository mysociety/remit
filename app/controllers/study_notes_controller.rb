class StudyNotesController < ApplicationController
  def create
    @study = Study.find(params[:study_id])
    @study_note = StudyNote.new(study_note_params)
    @study_note.study = @study
    if @study_note.save
      redirect_to @study, notice: "Note created successfully"
    else
      flash[:alert] = "Sorry, looks like we're missing something, can you " \
                      "double check?"
      render "studies/show"
    end
  end

  private

  def study_note_params
    params.require(:study_note).permit(:notes)
  end
end
