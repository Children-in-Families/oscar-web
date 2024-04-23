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
    end
  end
end
