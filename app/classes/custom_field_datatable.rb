class CustomFieldDatatable < ApplicationDatatable
  def initialize(view)
    @view = view
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
    CustomField.client_forms.order("lower(#{sort_column}) #{sort_direction}").page(page).per(per_page)
  end

  def columns
    %w(form_title copy)
  end

  def column_custom_fields
    @fetch_custom_fields.map{ |c| [c.form_title, link_custom_field(c)] }
  end

  def link_custom_field(custom_field)
    link_to new_multiple_form_custom_field_client_custom_field_path(custom_field), class: 'btn btn-primary btn-sm' do
      I18n.t('dashboards.custom_fields_tab.open_form')
    end
  end

  def total_entries
    @fetch_custom_fields.total_count
  end
end
