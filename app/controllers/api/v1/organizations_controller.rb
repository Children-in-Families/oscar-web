module Api
  module V1
    class OrganizationsController < ApplicationController
      def index
        render json: Organization.visible.order(:created_at)
      end
    end
  end
end
