module Api
  module V2
    class DomainGroupsController < Api::V1::BaseApiController
      def index
        render json: DomainGroup.all
      end
    end
  end
end
