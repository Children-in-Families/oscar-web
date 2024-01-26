module Api
  module V1
    class ProgramStreamsController < Api::V1::BaseApiController
      def index
        render json: ProgramStream.complete.ordered, scope: view_context
      end
    end
  end
end
