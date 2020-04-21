module Api
  module V1
    class DomainGroupsController < Api::V1::BaseApiController
      before_action :authenticate_user!

      def index
        render json: DomainGroup.all
      end
    end
  end
end
