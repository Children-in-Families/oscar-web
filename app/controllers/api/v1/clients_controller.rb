module Api
  module V1
    class ClientsController < Api::V1::BaseApiController

      def index
        render json: Client.accessible_by(current_ability)
      end

      def search
        render json: query 
      end

      private

      def query
        binding.pry
        
      end
    end
  end
end
