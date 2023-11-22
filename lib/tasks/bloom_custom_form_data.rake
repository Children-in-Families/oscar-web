namespace :bloom_custom_form_data do
  desc 'import Bloom custom form data'
  task import: :environment do
    Apartment::Tenant.switch 'ba'
    path = Rails.root.join('vendor/data/organizations/Historical_Records_for_Importing.xlsx')
    workbook = Roo::Excelx.new(path)
    sheet_index = workbook.sheets.index('All data')
    workbook.default_sheet = workbook.sheets[sheet_index]
    headers = workbook.row(1)
    custom_form = CustomField.find_by(form_title: 'Historical Records')
    (2..(workbook.last_row)).each do |index|
      values = workbook.row(index)
      code, student, incident_date, comment_type, comments = values
      client = Client.find_by(code: code)
      property_hash = headers[1..-1].zip(values[1..-1]).to_h
      custom_field_property = client.custom_field_properties.find_by(custom_field_id: custom_form.id)
      custom_field_property.properties = property_hash
      custom_field_property.save
    end
  end
end
