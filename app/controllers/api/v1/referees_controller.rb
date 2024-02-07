module Api
  module V1
    class RefereesController < Api::V1::BaseApiController
      def index
        referees = ActiveModel::ArraySerializer.new(Referee.cache_all, each_serializer: RefereeSerializer)
        render json: referees, root: 'referees'
      end
    end
  end
end
