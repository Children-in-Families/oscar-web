namespace :nepali_provinces do
  desc "Import Nepali addesses"
  task import: :environment do
    Organization.switch_to 'nepal'
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet.open Rails.root.join('vendor/data/organizations/nepal_provinces_and_districts_with_postal_code.xls')
    book.worksheets.each_with_index do |sheet, index|
      next if index == 0
      province_name = sheet.row(0).first
      district_types = sheet.row(1).compact
      province = Province.find_or_create_by(name: province_name) if province_name.present?
      if province
        sheet.rows[2..-1].each do |district_name, rural_postal_code, rural_commune_name, urban_postal_code, urban_commune_name|
          next if [district_name, rural_commune_name, urban_commune_name].all?(&:blank?)
          puts "#{province_name}: #{district_name}"
          district_postal_code = rural_postal_code && rural_postal_code.to_i.to_s[0..2]
          district = province.districts.find_or_initialize_by(name: district_name) do |district|
            district.code = district_postal_code if district_postal_code != "0"
            district.save
          end
          if district_name
            if rural_postal_code && rural_postal_code.to_i != 0
              district.communes.find_or_create_by(name_kh: rural_commune_name, name_en: rural_commune_name, district_type: district_types[2], code: rural_postal_code.to_i.to_s) if rural_commune_name
            else
              if rural_commune_name
                district.communes.find_or_initialize_by(name_kh: rural_commune_name, name_en: rural_commune_name, district_type: district_types[2]) do |commune|
                  commune.save(validate: false)
                end
              end
            end
            if rural_postal_code && urban_postal_code.to_i != 0
              district.communes.find_or_create_by(name_kh: urban_commune_name, name_en: urban_commune_name, district_type: district_types[4], code: urban_postal_code.to_i.to_s) if urban_commune_name
            else
              if rural_commune_name
                district.communes.find_or_initialize_by(name_kh: urban_commune_name, name_en: urban_commune_name, district_type: district_types[4]) do |commune|
                  commune.save(validate: false)
                end
              end
            end
          end
        end
      end
    end
  end

end
