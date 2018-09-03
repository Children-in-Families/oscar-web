module VillageImporter
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(file_name)
      @path     = "vendor/data/villages/xlsx/#{file_name}"
      @workbook = Roo::Excelx.new(path)

      province_name_en = workbook.sheets.first
      @province = Province.where('name ilike ?', "%#{province_name_en}%").first
      sheet_index = workbook.sheets.index(province_name_en)
      workbook.default_sheet = workbook.sheets[sheet_index]
      sheet_header
    end

    def sheet_header
      @headers = Hash.new
      workbook.row(3).each_with_index {|header,i|
        headers[header] = i
      }
    end

    def communes_and_villages
      ((workbook.first_row + 3)..workbook.last_row).each do |row|
        type    = workbook.row(row)[headers['Type']].squish
        name_kh = workbook.row(row)[headers['Name (Khmer)']].squish
        name_en = workbook.row(row)[headers['Name (Latin)']].squish
        code    = workbook.row(row)[headers['Code']].squish
        if ['ក្រុង', 'ស្រុក', 'ខណ្ឌ'].include?(type)
          district = @province.districts.where('name ilike ?', "%#{name_en}%").first if @province.present?

          begin
            code = "%06d" % code.to_i
          rescue
            if Rails.env == 'development'
              binding.pry
            else
              Rails.logger.debug e
            end
          end

          district.update(code: code) if district.present?

        elsif ['ឃុំ', 'សង្កាត់'].include?(type)
          district_code = code.length == 5 ? "0#{code[0..2]}" : code[0..3]

          begin
            district_code = "%06d" % district_code.to_i
          rescue
            if Rails.env == 'development'
              binding.pry
            else
              Rails.logger.debug e
            end
          end
          district = District.find_by(code: district_code)

          begin
            code = "%06d" % code.to_i
          rescue
            if Rails.env == 'development'
              binding.pry
            else
              Rails.logger.debug e
            end
          end

          district.communes.find_or_create_by(code: code, name_kh: name_kh, name_en: name_en) if district.present?
        elsif type == 'ភូមិ'
          commune_code = code.length == 7 ? code[0..4] : code[0..5]

          begin
            commune_code = "%06d" % commune_code.to_i
          rescue
            if Rails.env == 'development'
              binding.pry
            else
              Rails.logger.debug e
            end
          end

          commune = Commune.find_by(code: commune_code)

          begin
            code = "%08d" % code.to_i
          rescue
            if Rails.env == 'development'
              binding.pry
            else
              Rails.logger.debug e
            end
          end

          commune.villages.find_or_create_by(code: code, name_kh: name_kh, name_en: name_en) if commune.present?
        end
      end
    end
  end
end
