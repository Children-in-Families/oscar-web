module Api
  module V1
    class UsersController < Api::V1::BaseApiController

      def index
        users = User.self_and_subordinates(current_user)
        render json: users
      end

    end
  end
end