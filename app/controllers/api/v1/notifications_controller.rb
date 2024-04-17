module Api
  module V1
    class NotificationsController < Api::V1::BaseApiController
      def index
        notifications = current_user.fetch_notification
        render json: notifications
      end
    end
  end
end
