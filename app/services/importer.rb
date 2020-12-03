module Importer
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = 'vendor/data/basic_data_v7.xlsx')
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
        name = workbook.row(row)[headers['name']]
        name_en = workbook.row(row)[headers['name_en']]

        ReferralSource.create(
          name: name,
          name_en: name_en
        )
      end
    end

    def quantitative_types
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        name = workbook.row(row)[headers['Name']]

        QuantitativeType.create(
          name: name,
          visible_on: ['client']
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

  class Data
    attr_reader :province_id, :path
    def initialize(province_id, path)
      @path = path
      @province_id = province_id
      workbook
    end

    def workbook
      @workbook ||= Roo::Excelx.new(path)
    end

    def import
      commune_id = nil
      district_id = nil
      (4..(workbook.last_row)).each do |index|
        fields = %w(code name_kh name_en)
        values = workbook.row(index)

        row_type = values.first
        if row_type.strip == "ស្រុក" || row_type.strip == "ខណ្ឌ" || row_type.strip == "ក្រុង"
          attributes = {}
          attributes['name'] = "#{values[2].squish} / #{values[3].squish}".squish
          attributes['code'] = values[1].squish
          attributes['province_id'] = province_id

          pp attributes
          district = District.find_or_create_by(attributes)
          district_id = district&.id
          pp district_id
        elsif row_type.strip == "ឃុំ" || row_type.strip == "សង្កាត់"
          data = values[1..3].map(&:squish)
          data << district_id

          fields << 'district_id'
          attributes = [fields, data].transpose.to_h
          commune = Commune.find_or_create_by(attributes)
          commune_id = commune&.id
        else
          data = values[1..3].map(&:squish)
          data << commune_id

          fields << 'commune_id'
          attributes = [fields, data].transpose.to_h
          Village.find_or_create_by(attributes)
        end
      end

      puts "Done #{path} !!!"
    end
  end
end
