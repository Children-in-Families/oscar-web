module Importer
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = 'vendor/data/basic_data_v6.xlsx')
      @path     = path
      @workbook = Roo::Excelx.new(path)

      sheet_index = workbook.sheets.index(sheet_name)
      workbook.default_sheet = workbook.sheets[sheet_index]
      sheet_header
    end

    def sheet_header
      @headers = Hash.new
      workbook.row(1).each_with_index {|header,i|
        headers[header] = i
      }
    end

    def agencies
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        name = workbook.row(row)[headers['Name']]
        Agency.create(
          name: name
        )
      end
    end

    def departments
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        name = workbook.row(row)[headers['Name']]

        Department.create(
          name: name
        )
      end
    end

    def provinces
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        name = workbook.row(row)[headers['Name']]

        Province.create(
          name: name
        )
      end
    end

    def districts
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        name          = workbook.row(row)[headers['District Name']].squish
        name_en       = workbook.row(row)[headers['District Name EN']].squish
        province_name = workbook.row(row)[headers['Province Name EN']].squish
        province   = Province.find_by('name iLIKE ?', "%#{province_name}%")
        full_name = "#{name} / #{name_en}"
        District.find_or_create_by(
          name: full_name,
          province: province
        )
      end
    end

    def referral_sources
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        name = workbook.row(row)[headers['Name']]

        ReferralSource.create(
          name: name
        )
      end
    end

    def quantitative_types
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        name = workbook.row(row)[headers['Name']]

        QuantitativeType.create(
          name: name
        )
      end
    end

    def quantitative_cases
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        value   = workbook.row(row)[headers['Name']]
        type    = workbook.row(row)[headers['Type']]
        type_id = QuantitativeType.find_by(name: type).id

        QuantitativeCase.create(
          value: value,
          quantitative_type_id: type_id
        )
      end
    end
  end
end
