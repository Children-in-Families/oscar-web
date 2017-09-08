class ProgramStreamDatatable < ApplicationDatatable
  def column_custom_fields
    fetch_custom_fields.map{ |c| [c.form_title, c.entity_type, c.ngo_name, link_custom_field(c)] }
  end

  def link_custom_field(custom_field)
    link_to('#', class: 'copy-form', data: { fields: custom_field.fields.to_json }) do
      fa_icon('copy')
    end
  end

  def count
    CustomField.count
  end

  def total_entries
    fetch_custom_fields.total_count
  end

  def fetch_custom_fields
    if @ngo_custom_field == 'current_custom_field'
      custom_fields = CustomField.order(:entity_type, :form_title)
    elsif @ngo_custom_field == 'all_custom_field'
      custom_fields = find_custom_field_in_organization
    elsif @ngo_custom_field == 'demo_custom_field'
      custom_fields = find_custom_field_in_organization('demo')
    end
    custom_fields = Kaminari.paginate_array(custom_fields).page(page).per(per_page)
  end

  def columns
    %w(form_title entity_type ngo_name copy)
  end

  def find_custom_field_in_organization(org = '')
    current_org_name = Organization.current.short_name
    organizations = org == 'demo' ? Organization.where(short_name: 'demo') : Organization.without_demo.order(:full_name)
    custom_fields = organizations.map do |org|
      Organization.switch_to org.short_name
      CustomField.order(:entity_type, :form_title).reload
    end
    Organization.switch_to(current_org_name)
    custom_fields = custom_fields.flatten
  end
end
