module ImportVietnamAddress
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(path)
      @path = path
      @workbook = Roo::Excelx.new(path)
    end

    def import
      province_for_vietnam
      district_for_vietnam
    end

    def province_for_vietnam
      sheet_index = workbook.sheets.index('Province')
      workbook.default_sheet = workbook.sheets[sheet_index]
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        name = workbook.row(row)[0]
        code = workbook.row(row)[1]
        next if name.nil?

        Province.find_or_create_by(name: name, code: code, country: 'vietnam')
      end
    end

    def district_for_vietnam
      sheet_index = workbook.sheets.index('Province and district')
      workbook.default_sheet = workbook.sheets[sheet_index]

      province = nil

      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        next if workbook.row(row)[0] == 'Name'

        province_name = workbook.row(row)[0]

        if ['Ha Noi', 'Ho Chi Minh'].include?(province_name)
          province = Province.find_by(name: province_name)
          next
        end

        name = workbook.row(row)[0]
        code = workbook.row(row)[1]

        District.find_or_create_by(province_id: province.id, name: name, code: code) if province.present?
      end
    end

    private

    def sheet_header
      @headers = Hash.new
      workbook.row(1).each_with_index { |header, i|
        headers[header] = i
      }
    end
  end
end
