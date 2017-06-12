module Api
  module V1
    class UsersController < Api::V1::BaseApiController

      def index
        render json: User.all
      end

    end
  end
end