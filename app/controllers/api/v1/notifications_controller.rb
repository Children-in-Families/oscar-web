module Api
  module V1
    class NotificationsController < Api::V1::BaseApiController
      include NotificationConcern

      def index
        notifications = current_user.fetch_notification
        render json: notifications
      end

      def referrals
        render json: mapping_referrals
      end

      def repeat_referrals
        render json: mapping_repeated_referrals
      end

      def repeat_family_referrals
        render json: mapping_repeat_family_referrals
      end

      def notify_user_custom_field
        render json: mapping_notify_user_custom_field
      end

      def notify_family_custom_field
        render json: mapping_notify_family_custom_field
      end

      def notify_partner_custom_field
        render json: mapping_notify_partner_custom_field
      end

      def notify_overdue_case_note
        render json: mapping_notify_overdue_case_note
      end

      def notify_task
        render json: mapping_notify_task
      end

      def notify_assessment
        render json: mapping_notify_assessment
      end

      def notify_custom_assessment
        render json: mapping_notify_custom_assessment
      end

      def notify_client_custom_form
        render json: mapping_notify_client_custom_form
      end

      def program_stream_notify
        program_stream = ProgramStream.find(params[:program_stream_id])
        clients = Client.non_exited_ngo.where(id: params[:client_ids])
        render json: { program_stream_name: program_stream.name, clients: clients.map { |client| [client.slug, client.en_and_local_name] } }
      end
    end
  end
end
