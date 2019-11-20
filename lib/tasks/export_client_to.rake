namespace :export_client_to do
  desc "Export client to CSC"
  task csv: :environment do
    headers = ['org_name', 'client_id', 'province_id', 'Province name', 'district_id', 'District name', 'commune_id', 'Commune name', 'village_id', 'Village name']
    row_index = 0
    workbook = WriteXLSX.new("#{Rails.root}/clients-#{Date.today}.xlsx")
    worksheet = workbook.add_worksheet
    format = workbook.add_format
    format.set_align('center')

    Organization.pluck(:short_name).each do |short_name|
      next if short_name == 'shared'
      Organization.switch_to short_name

      if row_index == 0
        headers.each_with_index do |header, header_index|
          worksheet.write(0, header_index, header, format)
        end
      end

      Client.all.each do |client|
        province_id = client.province_id
        next if client.district_id.nil? || client.province_id == client.district.province_id

        columns = [
                short_name, client.id, client.province_id,
                client.province.name, client.district_id, client.district.name,
                client.commune_id, client.commune.try(:name), client.village_id, client.village.try(:name)
              ]

        row_index += 1
        columns.each_with_index do |column, column_index|
          worksheet.write(row_index, column_index, column, format)
        end
      end
    end
    workbook.close
  end
end
