module ImportThaiSubAddress
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(path)
      @path = path
      @workbook = Roo::Excelx.new(path)
    end

    def import
      subdistricts
    end

    def subdistricts
      sheets = workbook.sheets
      sheets.each do |sheet|
        workbook.default_sheet = sheet
        ((workbook.first_row + 2)..workbook.last_row).each do |row|
          district_name = workbook.row(row)[0]
          # district_thai_name = workbook.row(row)[1]
          sub_district_name = workbook.row(row)[2]
          sub_district_thai_name = workbook.row(row)[3]

          district = District.find_by(name: district_name)
          next unless district
          next if Subdistrict.exists?(name: sub_district_name, district_id: district.id)

          Subdistrict.find_or_create_by(
            name: sub_district_name
          ) do |subdistrict|
            subdistrict.name = "(#{sub_district_thai_name}) / #{sub_district_name}"
            subdistrict.district = district
          end
        end
      end
    end
  end
end
