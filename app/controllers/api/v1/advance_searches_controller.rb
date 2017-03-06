module Api
  module V1
    class AdvanceSearchesController < ApplicationController

      def index
        binding.pry
        render json: query, status: :ok, serializer: nil
      end

      private

      def query
        ClientAdvanceFilter.new(params[:search_rules]).client_queries
      end
    end
  end
end