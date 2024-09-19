module Api
  class CustomFieldsController < Api::ApplicationController
    before_action :find_custom_field, only: :fields

    def fetch_custom_fields
      render json: find_custom_field_in_organization
    end

    def fields
      properties = Hash.new { |h,k| h[k] = []}
      custom_field_property_ids = CustomFieldProperty.by_custom_field(@custom_field).ids
      file_uploader = FormBuilderAttachment.find_by_form_buildable(custom_field_property_ids, 'CustomFieldProperty').where("form_builder_attachments.file != '[]'").pluck(:name)
      @custom_field.custom_field_properties.pluck(:properties).map{ |props| props.each{ |k, v| properties[k] << v if (v && v.first.present?) } }

      custom_field_keys = properties.keys + file_uploader
      render json: { fields: custom_field_keys }
    end

    def ngo_custom_fields
      render json: CustomFormTrackingDatatable.new(view_context, params[:ngo_custom_field], params[:entity_type]), root: :data
    end

    def list_custom_fields

      form_type = params[:type]
      @custom_field_data ||= CustomFieldDatatable.new(view_context, form_type)
      render json: @custom_field_data, root: :data
    end

    private

    def find_custom_field_in_organization
      current_org_name = Organization.current.short_name
      orgs = current_org_name == 'demo' ? Organization.all : Organization.without_demo.order(:full_name)
      custom_fields = orgs.map do |org|
        Organization.switch_to org.short_name
        CustomField.order(:entity_type, :form_title).reload
      end
      Organization.switch_to(current_org_name)
      { custom_fields: custom_fields.flatten }
    end

    def find_custom_field
      if params[:type] == 'CaseNotes::CustomField'
        @custom_field = CaseNotes::CustomField.find(params[:custom_field_id])
        return
      end

      @custom_field = CustomField.find(params[:custom_field_id])
    end
  end
end
