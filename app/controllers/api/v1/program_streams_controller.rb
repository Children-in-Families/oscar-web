module Api
  module V1
    class ProgramStreamsController < Api::V1::BaseApiController
      before_action :authenticate_user!

      def index
        render json: ProgramStream.complete.ordered
      end
    end
  end
end
