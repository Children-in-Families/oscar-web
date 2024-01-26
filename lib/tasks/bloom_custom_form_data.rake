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
    values = (2..(workbook.last_row)).map do |index|
      values = workbook.row(index)
      code, student, incident_date, comment_type, comments = values
      client = Client.find_by(code: code)
      next if client.nil?

      property_hash = headers[1..-1].zip([student, incident_date, comment_type, (comments || '').gsub("'", "''")]).to_h
      "('#{client.id}', 'Client', #{custom_form.id}, '#{property_hash.to_json}', now(), now())"
    end.compact.join(',')

    ActiveRecord::Base.connection.execute("INSERT INTO ba.custom_field_properties (custom_formable_id, custom_formable_type, custom_field_id, properties, created_at, updated_at) VALUES #{values}")
  end
end
