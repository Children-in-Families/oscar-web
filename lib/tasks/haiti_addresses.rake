namespace :haiti_addresses do
  desc "Import Haiti haiti_addresses"
  task :import, [:short_name] => :environment do |task, args|
    Organization.switch_to args.short_name

    path = Rails.root.join("lib/devdata/Haiti_Administrative_Divisions.xlsx")
    workbook = Roo::Excelx.new(path)
    workbook.default_sheet = 'Sheet1'
    province_id = nil
    district_id = nil
    (2..workbook.last_row).each do |row_index|
      rows = workbook.row(row_index)
      province_name, district_name, commune_name = rows
      begin
        province_id = Province.find_or_create_by(name: province_name, country: 'haiti').id if province_name
        district_id = District.find_or_initialize_by(name: district_name) do |district|
          district.province_id = province_id
          district.code = "#{province_id}#{row_index}"
          district.save
        end.id if province_id && district_name
        commune = Commune.find_or_initialize_by(name_en: commune_name) do |commune|
          commune.name_kh = commune_name
          commune.district_id = district_id
          commune.code = "#{province_id}#{district_id}#{row_index}"
          commune.district_type = 'haiti'
          commune.save
        end if district_id && commune_name
      rescue => exception
        puts exception
      end
    end
  end
end
