module Api
  module V1
    class NotificationsController < Api::V1::BaseApiController
      def index
        clients = Client.none.accessible_by(current_ability).non_exited_ngo
        @notifications = UserNotification.new(current_user, clients)
        render json: @notifications
      end
    end
  end
end
