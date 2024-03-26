module Api
  module V1
    class NotificationsController < Api::V1::BaseApiController
      include NotificationMappingConcern

      def index
        clients = Client.accessible_by(current_ability).non_exited_ngo
        notifications = UserNotification.new(current_user, clients)
        notifications = JSON.parse(notifications.to_json)

        render json: map_notification_payloads(notifications)
      end
    end
  end
end
