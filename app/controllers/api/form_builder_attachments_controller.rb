module Api
  class FormBuilderAttachmentsController < Api::ApplicationController
    before_action :find_attachment

    def destroy
      index = params[:file_index].to_i
      remain_file  = @attachment.file
      deleted_file = remain_file.delete_at(index)
      deleted_file.try(:remove!)
      remain_file.empty? ? @attachment.remove_file! : @attachment.file = remain_file
      @attachment.save
      message ||= t('.successfully_deleted')
      respond_to do |f|
        f.json { render json: { message: message }, status: '200' }
      end
    end

    private

    def find_attachment
      id = params[:id]
      name = params[:file_name]
      @attachment = FormBuilderAttachment.find_by(id: id, name: name)
    end
  end
end
