module Api
  module V1
    class ReleaseNotesController < Api::V1::BaseApiController
      skip_before_action :authenticate_user!
      before_action :authenticate_admin_user!

      def upload_attachments
        release_note = ReleaseNote.find(params[:id])
        release_note.update_attributes(attachments: params[:attachments])

        render json: { success: true }
      end

      def authenticate_admin_user!
        authenticate_or_request_with_http_token do |token, _options|
          @current_user = AdminUser.find_by(token: token)
        end
      end
    end
  end
end
