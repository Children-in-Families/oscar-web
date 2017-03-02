module Api
  module V1
    class AdvanceSearchesController < ApplicationController

      def index
        render json: query 
      end

      private

      def query
        ClientAdvanceFilter.new(params[:search_rules]).client_queries
      end
    end
  end
end