module Api
  module V1
    class CustomFieldsController < Api::V1::BaseApiController
      def index
        custom_forms = CustomField.cache_all
        render json: custom_forms
      end
    end
  end
end
