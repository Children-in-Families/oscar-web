module Api
  module V1
    class OrganizationsController < ApplicationController
      def index
        render json: Organization.order(:created_at)
      end
    end
  end
end
