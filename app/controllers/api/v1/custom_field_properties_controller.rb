module Api
  module V1
    class CustomFieldPropertiesController < Api::V1::BaseApiController
      include CustomFieldPropertiesConcern
      include FormBuilderAttachments

      before_action :find_entity
      before_action :find_custom_field_property, only: %i[update destroy]

      def index
        custom_field_properties = @custom_formable.custom_field_properties
        render json: custom_field_properties
      end

      def create
        form_builder_attachments_attributes = params.require(:custom_field_property)[:form_builder_attachments_attributes].try(:clone) || {}
        custom_field_property = @custom_formable.custom_field_properties.new(custom_field_property_params)
        custom_field_property.user_id = current_user.id
        if custom_field_property.save
          custom_field_property.form_builder_attachments.map do |c|
            name_value = c.name
            attachments = map_attachments_attribute(form_builder_attachments_attributes, params[:custom_field_id])
            attachments.each { |_, hash| name_value = hash['name'] if hash['label'] == c.name }
            custom_field_property.properties = custom_field_property.properties.merge({ name_value => c.file })
            custom_field_property.save(validate: false)
            c.name = name_value
            c.save
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
            render json: { error: 'Failed deleting attachment' }
          end
        elsif @custom_field_property.destroy
          head 204
        else
          render json: { error: 'Failed deleting custom field property' }
        end
      end

      private

      def find_custom_field_property
        @custom_field_property = @custom_formable.custom_field_properties.find(params[:id])
      end

      def custom_field_property_params
        if properties_params.present?
          mappings = {}
          properties_params.each do |k, _|
            mappings[k] = k.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('%22', '"')
          end
          formatted_params = properties_params.map { |k, v| [mappings[k], v] }.to_h
          formatted_params.values.map { |v| v.delete('') if (v.is_a? Array) && v.size > 1 }
        end
        default_params = params.require(:custom_field_property).permit({}).merge(custom_field_id: params[:custom_field_id])
        default_params = default_params.merge(properties: formatted_params) if formatted_params.present?
        default_params = default_params.merge(form_builder_attachments_attributes: attachment_params) if action_name == 'create' && attachment_params.present?
        property_params = mapping_custom_name_with_label(params[:custom_field_id], default_params)

        default_params.merge(property_params)
      end

      def mapping_custom_name_with_label(custom_field_id, custom_field_property_attribute)
        custom_field = CustomField.find(custom_field_id)
        properties = map_property_attribute(custom_field_property_attribute[:properties], custom_field)

        custom_field_property_attribute.merge(properties: properties)
      end

      def map_property_attribute(properties, custom_field)
        properties.transform_keys do |key|
          custom_field.fields.each do |field|
            key = field['label'] if field['name'] == key
          end
          key
        end
      end

      def map_attachments_attribute(attachment_attributes, custom_field)
        (attachment_attributes || []).each do |k, value|
          file_labels = {}
          custom_field.fields.each do |field|
            next unless field['type'] == 'file'

            file_labels = value.merge({ name: field['label'], label: value['name'] }) if field['name'] == value['name']
          end

          attachment_attributes[k.to_sym] = file_labels
        end

        attachment_attributes
      end
    end
  end
end
