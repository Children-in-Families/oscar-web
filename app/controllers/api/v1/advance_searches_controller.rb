module Api
  module V1
    class AdvanceSearchesController < AdminController
      def index
        @advanced_filter_fields = ClientAdvancedFilterFields.new(user: current_user).render
        render json: @advanced_filter_fields
      end
    end
  end
end
