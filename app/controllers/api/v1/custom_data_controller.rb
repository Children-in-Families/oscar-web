module Api
  module V1
    class CustomDataController < Api::V1::BaseApiController
      before_action :find_client, only: [:create, :update]

      def show
        custom_data = CustomData.first
        render json: custom_data || {}
      end

      def create
        client_custom_data = @client.build_client_custom_data(client_custom_data_params)
        if client_custom_data.save
          render json: client_custom_data
        else
          render json: client_custom_data.errors, status: :unprocessable_entity
        end
      end

      def update
        client_custom_data = @client.client_custom_data
        if client_custom_data.update(client_custom_data_params)
          render json: client_custom_data
        else
          render json: client_custom_data.errors, status: :unprocessable_entity
        end
      end

      private

      def client_custom_data_params
        param_array = []
        params.dig(:client_custom_data, :properties).each { |k, v| param_array << [k, v.first.is_a?(Hash) ? v.first.keys : []] if v.is_a?(Array) }
        property_keys = params.dig(:client_custom_data, :properties).try(:keys)

        params.require(:client_custom_data).permit(
          :custom_data_id,
          properties: property_keys << param_array.to_h,
          form_builder_attachments_attributes: [:id, :name, { file: [] }]
        )
      end

      def find_client
        @client = Client.find(params[:client_id])
      end
    end
  end
end
