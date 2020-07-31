namespace :nepali_provinces do
  desc "Import Nepali addesses"
  task import: :environment do
    Organization.switch_to 'nepal'
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet.open Rails.root.join('vendor/data/organizations/nepali_provinces.xls')
    random_code = "0100"
    book.worksheets.each_with_index do |sheet, index|
      next if index == 0
      province_name = sheet.row(0).first
      district_types = sheet.row(1).compact
      province = Province.find_or_create_by(name: province_name) if province_name.present?
      if province
        sheet.rows[2..-1].each do |district_name, rural_commune_name, urban_commune_name|
          random_code = "0101".succ
          next if [district_name, rural_commune_name, urban_commune_name].all?(&:blank?)
          puts "#{province_name}: #{district_name}"
          district = province.districts.find_or_create_by(name: district_name, code: random_code)
          if district_name
            commune_code = district.communes.last&.code.blank? ? "#{district.code}00" : "#{district.communes.last.code}"
            district.communes.find_or_create_by(name_kh: rural_commune_name, name_en: rural_commune_name, district_type: district_types[1], code: commune_code.succ) if rural_commune_name
            district.communes.find_or_create_by(name_kh: urban_commune_name, name_en: urban_commune_name, district_type: district_types[2], code: commune_code.succ.succ) if urban_commune_name
          end
        end
      end
    end
  end

end
