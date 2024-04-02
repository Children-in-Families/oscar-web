module Api
  module V1
    class ServicesController < Api::V1::BaseApiController
      include ProgramStreamHelper

      def index
        render json: Service.all
      end
    end
  end
end
