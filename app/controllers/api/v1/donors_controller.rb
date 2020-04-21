module Api
  module V1
    class DonorsController < Api::V1::BaseApiController
      before_action :authenticate_user!

      def index
        render json: Donor.order(:name)
      end
    end
  end
end
