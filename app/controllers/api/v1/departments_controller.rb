module Api
  module V1
    class DepartmentsController < Api::V1::BaseApiController
      before_action :authenticate_user!

      def index
        render json: Department.all
      end
    end
  end
end
