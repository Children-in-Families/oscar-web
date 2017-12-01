module Api
  module V1
    class ProgramStreamsController < Api::V1::BaseApiController
      def index
        render json: ProgramStream.all
      end
    end
  end
end
