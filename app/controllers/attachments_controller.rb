class AttachmentsController < AdminController
  def index
    @attachments = Attachment.where(progress_note_id: params[:progress_note_id])
    render json: @attachments, status: 200
  end
end
