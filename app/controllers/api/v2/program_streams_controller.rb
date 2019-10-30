module Api
  module V2
    class ProgramStreamsController < Api::V1::BaseApiController
      def index
        render json: ProgramStream.complete.ordered
      end
    end
  end
end
