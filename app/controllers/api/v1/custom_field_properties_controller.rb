module Api
  module V1
    class CustomFieldPropertiesController < Api::V1::BaseApiController
      include FormBuilderAttachments
      before_action :find_entity
      before_action :find_custom_field_property, only: [:update, :destroy]

      def create
        custom_field_property = @custom_formable.custom_field_properties.new(custom_field_property_params)
        if custom_field_property.save
          custom_field_property.form_builder_attachments.map do |c|
            custom_field_property.properties = custom_field_property.properties.merge({ c.name => c.file })
          end
          render json: custom_field_property
        else
          render json: custom_field_property.errors, status: :unprocessable_entity
        end
      end

      def update
        if @custom_field_property.update_attributes(custom_field_property_params) && @custom_field_property.save
          add_more_attachments(@custom_field_property)
          @custom_field_property.form_builder_attachments.map do |c|
            @custom_field_property.properties = @custom_field_property.properties.merge({ c.name => c.file })
          end
          render json: @custom_field_property
        else
          render json: @custom_field_property.errors, status: :unprocessable_entity
        end
      end

      def destroy
        name = params[:file_name]
        index = params[:file_index].to_i
        if name.present? && index.present?
          if delete_form_builder_attachment(@custom_field_property, name, index)
            head 204 if @custom_field_property.save
          else
            render json: { error: "Failed deleting attachment" }
          end
        elsif @custom_field_property.destroy
          head 204
        else
          render json: { error: "Failed deleting custom field property" }
        end
      end

      private

      def find_custom_field_property
        @custom_field_property = @custom_formable.custom_field_properties.find(params[:id])
      end

      def custom_field_property_params
        custom_form_fields = CustomField.find(params[:custom_field_id]).fields.map{|c| [c['name'], c['label'], c['type']]}
        custom_form_fields.each do |name, label, type|
          if type == 'file' && attachment_params.present?
            attachment_params.values.each do |attachment|
              attachment['name'] = label if attachment['name'] == name
            end
          end
          if type != 'file' && properties_params.present?
            properties_params.keys.each do |key|
              properties_params[label] = properties_params.delete key if key == name
            end
          end
        end
        properties_params.values.map { |v| v.delete('') if (v.is_a? Array) && v.size > 1 } if properties_params.present?
        default_params = params.require(:custom_field_property).permit({}).merge(custom_field_id: params[:custom_field_id])
        default_params = default_params.merge(properties: properties_params) if properties_params.present?
        default_params = default_params.merge(form_builder_attachments_attributes: attachment_params) if action_name == 'create' && attachment_params.present?
        default_params
      end
    end
  end
end
