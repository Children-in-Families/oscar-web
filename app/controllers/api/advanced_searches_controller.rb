module Api
  class AdvancedSearchesController < AdminController
    def index
      @advanced_filter_fields = ClientAdvancedFilterFields.new(user: current_user).render
      render json: @advanced_filter_fields
    end
  end
end
