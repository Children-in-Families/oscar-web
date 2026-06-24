module GeonameData
  class Mapping
    attr_accessor :path, :headers, :workbook, :sheet, :province_name_kh, :province_name, :province_code

    def initialize(file_path, province_name_kh, province_name_en, province_code)
      @province_name = province_name_en
      @province_code = province_code
      @province_name_kh = province_name_kh

      @workbook = Roo::Excelx.new(file_path)
      sheet_index = 0

      workbook.default_sheet = workbook.sheets[sheet_index]
      sheet_header
      @book = Spreadsheet::Workbook.new

      xlsx_package = Axlsx::Package.new
      book = xlsx_package.workbook
      @sheet = book.add_worksheet(name: "#{province_name_en.capitalize} (#{province_code})")
      total_header = @sheet.styles.add_style fg_color: 'FFFFFF',
                                             b: true,
                                             bg_color: '004586',
                                             sz: 12,
                                             shrink_to_fit: true,
                                             border: { style: :thin, color: '00' },
                                             alignment: { horizontal: :center,
                                                          shrink_to_fit: true }

      output_file = "vendor/data/geoname_mapping/#{province_name_en.capitalize}_(#{province_code}).xlsx"

      communes_and_villages(xlsx_package, output_file, total_header)
    end

    def sheet_header
      @headers = Hash.new
      workbook.row(3).each_with_index do |header, i|
        headers[header] = i
      end
    end

    def communes_and_villages(xlsx_package, output_file, total_header)
      all_row_values = []
      title = ["#{province_name_kh} / #{province_name.capitalize} (#{province_code})"]
      row_headers = ['Adm1', 'Adm2', 'Adm3', 'Adm4']
      distinct_name = ''
      commune_name = ''

      sheet.add_row title, style: total_header
      sheet.add_row row_headers, style: total_header

      ((workbook.first_row + 3)..workbook.last_row).each do |row_index|
        row_values = title.dup
        3.times { row_values << '' }

        type = workbook.row(row_index)[headers['Type']].squish
        name_kh = workbook.row(row_index)[headers['Name (Khmer)']].squish
        name_en = workbook.row(row_index)[headers['Name (Latin)']].squish
        code = workbook.row(row_index)[headers['Code']].squish

        if ['ក្រុង', 'ស្រុក', 'ខណ្ឌ'].include?(type)
          distinct_name = "#{name_kh} / #{name_en} (#{code})"
          row_values[1] = distinct_name
        elsif ['ឃុំ', 'សង្កាត់'].include?(type)
          commune_name = "#{name_kh} / #{name_en} (#{code})"
          row_values[2] = commune_name
        elsif type == 'ភូមិ'
          row_values[1] = distinct_name
          row_values[2] = commune_name
          row_values[3] = "#{name_kh} / #{name_en} (#{code})"
        end
        all_row_values << row_values
      end

      all_row_values.reject { |row_value| row_value.reject(&:blank?).size != 4 }.each_with_index do |row_value, index|
        sheet.add_row row_value
      end

      xlsx_package.serialize(output_file)
    end
  end
end
