module Api
  module V1
    class CustomFieldPropertiesController < Api::V1::BaseApiController
      before_action :find_client
      before_action :find_custom_field_property, only: [:update, :destroy]

      def create
        custom_field_property = @client.custom_field_properties.new(custom_field_property_params)
        if custom_field_property.save
          render json: custom_field_property
        else
          render json: custom_field_property.errors, status: :unprocessable_entity
        end
      end

      def update
        attachments = params['custom_field_property']['attachments']
        add_more_attachments(attachments) if attachments.present?
        if @custom_field_property.update_attributes(custom_field_property_params) && @custom_field_property.save
          render json: @custom_field_property
        else
          render json: custom_field_property.errors, status: :unprocessable_entity
        end
      end

      def destroy
        if params[:file_index].present?
          remove_attachment_at_index(params[:file_index].to_i)
          render json: { error: "Failed deleting attachment" } unless @custom_field_property.save
        else
          @custom_field_property.destroy
        end
        head 204
      end

      private

      def find_custom_field_property
        @custom_field_property = @client.custom_field_properties.find(params[:id])
      end

      def custom_field_property_params
        default_params = params.require(:custom_field_property).permit({}).merge(properties: (params['custom_field_property']['properties']), custom_field_id: params[:custom_field_id])
        default_params = default_params.merge(attachments: (params['custom_field_property']['attachments'])) if action_name == 'create'
        default_params
      end

      def add_more_attachments(new_files)
        files = @custom_field_property.attachments
        files += new_files
        @custom_field_property.attachments = files
      end

      def remove_attachment_at_index(index)
        remain_attachment = @custom_field_property.attachments
        deleted_attachment = remain_attachment.delete_at(index)
        deleted_attachment.try(:remove!)
        remain_attachment.empty? ? @custom_field_property.remove_attachments! : (@custom_field_property.attachments = remain_attachment )
      end
    end
  end
end
