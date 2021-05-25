namespace :haiti_addresses do
  desc "Import Haiti haiti_addresses"
  task import: :environment do
    Organization.switch_to 'chi'
    path = Rails.root.join("vendor/data/organizations/Haiti_Administrative_Divisions.xlsx")
    workbook = Roo::Excelx.new(path)
    workbook.default_sheet = 'Sheet1'
    province_id = nil
    district_id = nil
    (2..workbook.last_row).each do |row_index|
      rows = workbook.row(row_index)
      rows.each do |province_name, district_name, commune_name|
        province_id = Province.find_or_create_by(name: province_name, country: 'haiti').id if province_name
        district_id = District.find_or_create_by(name: district_name, province_id: province_id, code: "#{province_id}#{row_index}").id if province_id && district_name
        Commune.find_or_create_by(name_en: commune_name, district_id: district_id, code: "#{province_id}#{district_id}#{row_index}") if district_id
      end
    end
  end

end
