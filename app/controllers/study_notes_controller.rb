class StudyNotesController < ApplicationController
  before_action :set_study_from_study_id, only: [:create]
  before_action :check_user_can_manage_study, only: [:create]

  def create
    @study_note = StudyNote.new(study_note_params)
    @study_note.study = @study
    @study_note.user = current_user
    if @study_note.save
      redirect_to @study, success: "Note created successfully"
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
