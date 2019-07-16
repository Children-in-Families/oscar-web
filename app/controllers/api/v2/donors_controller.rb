module Api
  module V2
    class DonorsController < Api::V1::BaseApiController
      def index
        render json: Donor.order(:name)
      end
    end
  end
end
