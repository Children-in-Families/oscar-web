module Api
  class ClientAdvancedSearchesController < AdminController
    def get_basic_field
      @advanced_filter_fields = AdvancedSearches::ClientFields.new(user: current_user).render
      render json: @advanced_filter_fields
    end

    def get_custom_field
      custom_form_id = params[:custom_form_id]
      @advanced_filter_custom_field = AdvancedSearches::CustomFields.new(user: current_user, custom_form_id: custom_form_id).render
      render json: @advanced_filter_custom_field
    end
  end
end
