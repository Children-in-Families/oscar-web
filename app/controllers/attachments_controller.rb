class AttachmentsController < AdminController
  load_and_authorize_resource
  before_action :find_client, :find_progress_note
  
  def show
    send_file @attachment.file.path,
              filename: File.basename(@attachment.file.path),
              type: @attachment.file.content_type,
              disposition: 'inline'
  end
  
  private

  def find_client
    @client = Client.able.accessible_by(current_ability).friendly.find(params[:client_id])
  end

  def find_progress_note
    @progress_note = @client.progress_notes.find(params[:progress_note_id])
  end

  def find_attachment
    @attachment = @progress_note.attachments.find(params[:id])
  end
end
