module Api
  module V1
    class UsersController < Api::V1::BaseApiController
      before_action :find_user

      def update
        if @user.update(user_params)
          render json: @user
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end

      private

      def find_user
        @user = User.find(params[:id])
      end

      def user_params
        params.require(:user).permit(:pin_number)
      end
    end
  end
end
