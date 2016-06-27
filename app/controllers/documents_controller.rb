class DocumentsController < ApplicationController
  before_action :set_study_from_study_id, only: [:create]
  before_action :check_user_can_manage_study, only: [:create]
  before_action :authenticate_user!, only: :show

  def show
    @document = Document.find(params[:id])
    send_file @document.document.path, type: @document.document_content_type,
                                       x_sendfile: true
  end

  def create
    @document = Document.new(document_params)
    @document.study = @study
    @document.user = current_user
    if @document.save
      redirect_to @study, success: "Document created successfully"
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
