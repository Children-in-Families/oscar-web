module Api
  class CustomFieldsController < AdminController
    def fetch_custom_fields
      render json: find_custom_field_in_organization
    end

    private

    def find_custom_field_in_organization
      current_org_name = current_organization.short_name
      custom_fields = []
      orgs = current_org_name == 'demo' ? Organization.all : Organization.without_demo
      orgs.each do |org|
        Organization.switch_to org.short_name
        custom_fields << CustomField.order(:entity_type, :form_title).reload
      end
      Organization.switch_to(current_org_name)
      custom_fields.flatten
    end
  end
end
