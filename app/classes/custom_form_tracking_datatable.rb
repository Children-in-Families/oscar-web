class CustomFormTrackingDatatable < ApplicationDatatable
  def initialize(view, ngo_custom_field)
    @view = view
    @ngo_custom_field = ngo_custom_field
    @fetch_custom_fields =  fetch_custom_fields
  end

  def as_json(options = {})
    {
      recordsFiltered: total_entries,
      data: column_custom_fields
    }
  end

  private

  def sort_column
    columns[params[:order]['0'][:column].to_i]
  end

  def fetch_custom_fields
    if @ngo_custom_field == 'current_custom_field'
      custom_fields = CustomField.client_forms.order("#{sort_column} #{sort_direction}")
    elsif @ngo_custom_field == 'all_custom_field'
      custom_fields = find_custom_field_in_organization
    elsif @ngo_custom_field == 'demo_custom_field'
      custom_fields = find_custom_field_in_organization('demo')
    end
    if custom_fields.is_a?(Array)
      custom_fields = sort_all(custom_fields)
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
      CustomField.client_forms.order(:entity_type, :form_title).reload
    end
    Organization.switch_to(current_org_name)
    custom_fields = custom_fields.flatten
  end

  def sort_all(custom_fields)
    ordered = custom_fields.sort_by{ |c| c[sort_column].downcase }
    sort_column.present? && sort_direction == 'desc' ? ordered.reverse : ordered
  end

  def column_custom_fields
    @fetch_custom_fields.map{ |c| [c.form_title, c.entity_type, c.ngo_name, link_custom_field(c)] }
  end

  def link_custom_field(custom_field)
    link_to('#', class: 'copy-form', data: { fields: custom_field.fields.to_json }) do
      fa_icon('copy')
    end
  end

  def total_entries
    @fetch_custom_fields.total_count
  end
end
