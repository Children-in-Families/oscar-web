class ProgramStreamDatatable < ApplicationDatatable
  def column_custom_fields
    @fetch_custom_fields.map{ |c| [c.form_title, c.entity_type, c.ngo_name, link_custom_field(c)] }
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
    @fetch_custom_fields.total_count
  end
end
