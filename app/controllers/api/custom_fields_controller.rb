module Api
  class CustomFieldsController < Api::ApplicationController
    def fetch_custom_fields
      render json: find_custom_field_in_organization
    end

    def fields
      custom_field = CustomField.find params[:custom_field_id]
      custom_field_property_ids = CustomFieldProperty.by_custom_field(custom_field).ids
      file_uploader = FormBuilderAttachment.find_by_form_buildable(custom_field_property_ids, 'CustomFieldProperty').where("form_builder_attachments.file != '[]'").pluck(:name)
      properties = custom_field.custom_field_properties.pluck(:properties).select(&:present?).map(&:keys).flatten.uniq
      properties += file_uploader
      render json: { fields: properties }
    end

    def ngo_custom_fields
      render json: ProgramStreamDatatable.new(view_context, params[:ngo_custom_field]), root: :data
    end

    private

    def find_custom_field_in_organization
      current_org_name = current_organization.short_name
      orgs = current_org_name == 'demo' ? Organization.all : Organization.without_demo.order(:full_name)
      custom_fields = orgs.map do |org|
        Organization.switch_to org.short_name
        CustomField.order(:entity_type, :form_title).reload
      end
      Organization.switch_to(current_org_name)
      { custom_fields: custom_fields.flatten }
    end
  end
end
