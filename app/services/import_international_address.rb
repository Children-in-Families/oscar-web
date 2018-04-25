module ImportInternationalAddress
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path)
      @path     = path
      @workbook = Roo::Excelx.new(path)

      sheet_index = workbook.sheets.index(sheet_name)
      workbook.default_sheet = workbook.sheets[sheet_index]
      sheet_header
    end

    def sheet_header
      @headers = Hash.new
      workbook.row(1).each_with_index { |header, i|
        headers[header] = i
      }
    end

    def province_for_thai
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        name = workbook.row(row)[headers['Name']]
        Province.find_or_create_by(name: name)
      end
    end

    def district_for_thai
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        province_name = workbook.row(row)[headers['Province']]
        name = workbook.row(row)[headers['Name']]
        province = Province.find_by(name: province_name)
        District.create(province_id: province.id, name: name) if province.present?
      end
    end

    def subdistrict_for_thai
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        district_name = workbook.row(row)[headers['District']]
        name = workbook.row(row)[headers['Name']]
        district = District.find_by(name: district_name)
        Subdistrict.create(district_id: district.id, name: name) if district.present?
      end
    end

    def state_for_myanmar
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        name = workbook.row(row)[headers['Name']]
        State.create(name: name)
      end
    end

    def township_for_myanmar
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        state_name = workbook.row(row)[headers['State']]
        name = workbook.row(row)[headers['Name']]
        state = State.find_by(name: state_name)
        Township.create(state_id: state.id, name: name) if state.present?
      end
    end
  end
end
