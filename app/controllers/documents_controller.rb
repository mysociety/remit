class DocumentsController < ApplicationController
  def create
    @study = Study.find(params[:study_id])
    @document = Document.new(document_params)
    @document.study = @study
    @document.user = current_user
    if @document.save
      redirect_to @study, notice: "Document created successfully"
    else
      flash[:alert] = "Sorry, looks like we're missing something, can you " \
                      "double check?"
      render "studies/show"
    end
  end

  private

  def document_params
    params.require(:document).permit(:document_type_id, :document)
  end
end
