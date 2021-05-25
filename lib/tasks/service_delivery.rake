namespace :service_delivery do
  desc "Create service delivery for Ratanak"
  task create: :environment do
    Organization.switch_to 'ratanak'
    path = Rails.root.join("vendor/data/organizations/service_delivery_llist.xlsx")
    workbook = Roo::Excelx.new(path)
    workbook.sheets.each do |sheet_name|
      service = ServiceDelivery.find_or_create_by(name: sheet_name.strip)

      sheet_index = workbook.sheets.index(sheet_name)
      workbook.default_sheet = workbook.sheets[sheet_index]
      column_values = workbook.column(1).split(nil)
      column_values.each do |values|
        if values.present?
          sub_cat_service = ServiceDelivery.find_or_create_by(name: values[0].strip, parent_id: service.id)
          values[1..-1] && values[1..-1].each do |value|
            if value.present?
              child = ServiceDelivery.find_or_create_by(name: value.strip, parent_id: sub_cat_service.id)
              puts "Main: #{service.name}: Subcat: #{sub_cat_service.name}: #{child.name}"
            end
          end
        end
      end
    end
  end
end
