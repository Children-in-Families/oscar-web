module Api
  module V1
    class ProgramStreamsController < Api::V1::BaseApiController
      def index
        program_streams = ProgramStream.all.map do |p|
          p.as_json.merge(tracking_fields: p.trackings)
        end
        render json: program_streams
      end
    end
  end
end
