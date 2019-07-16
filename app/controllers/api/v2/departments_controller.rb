module Api
  module V2
    class DepartmentsController < Api::V1::BaseApiController
      def index
        render json: Department.all
      end
    end
  end
end
