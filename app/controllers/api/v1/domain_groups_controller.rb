module Api
  module V1
    class DomainGroupsController < Api::V1::BaseApiController

      def index
        render json: DomainGroup.all
      end
    end
  end
end
