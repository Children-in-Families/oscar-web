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
        Agency.find_or_create_by(
          name: name
        )
      end
    end

    def departments
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        name = workbook.row(row)[headers['Name']]

        Department.find_or_create_by(
          name: name
        )
      end
    end

    def provinces
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        name = workbook.row(row)[headers['Name']]

        Province.find_or_create_by(
          name: name,
          country: 'cambodia'
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

        ReferralSource.find_or_create_by(
          name: name,
          name_en: name_en
        )
      end
    end

    def quantitative_types
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        name = workbook.row(row)[headers['Name']]

        QuantitativeType.find_or_create_by(
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

        QuantitativeCase.find_or_create_by(
          value: value,
          quantitative_type_id: type_id
        )
      end
    end
  end

  class Data
    attr_reader :path, :province_id
    attr_accessor :district_id, :commune_id

    def initialize(province_id, path)
      @path = path
      @province_id = province_id
      @district_id = nil
      @commune_id = nil
      workbook
    end

    def workbook
      @workbook ||= Roo::Excelx.new(path)
    end

    def import
      (4..workbook.last_row).each do |index|
        values = workbook.row(index)
        row_type = values.first.strip

        if ["ស្រុក", "ខណ្ឌ", "ក្រុង"].include?(row_type)
          import_district(values, district_id)
        elsif ["ឃុំ", "សង្កាត់"].include?(row_type)
          commune_id = import_commune(values, district_id)
        else
          import_village(values, commune_id)
        end
      end

      puts "Done #{path} !!!"
    end

    private

    def import_district(values, district_id)
      attributes = {
        name: "#{values[2].squish} / #{values[3].squish}".squish,
        code: values[1].squish.to_s.rjust(4, '0'),
        province_id: province_id
      }

      district = find_district(attributes[:code], province_id) || find_district(attributes[:code])

      if district
        district.update(attributes)
        district.reload
      else
        district = find_or_create_district(attributes)
      end

      district_id = district&.id
    end

    def import_commune(values, district_id)
      attributes = {
        name_kh: values[2].squish,
        name_en: values[3].squish,
        code: values[1].squish.to_s.rjust(6, '0'),
        district_id: district_id
      }

      commune = find_commune(attributes[:code], district_id) || find_commune(attributes[:code])

      if commune
        commune.update(attributes)
        commune.reload
      else
        commune = find_or_create_commune(attributes)
      end

      commune_id = commune&.id
    end

    def import_village(values, commune_id)
      attributes = {
        name_kh: values[2].squish,
        name_en: values[3].squish,
        code: values[1].squish.to_s.rjust(8, '0'),
        commune_id: commune_id
      }

      village = find_village(attributes[:code], commune_id) || find_village(attributes[:code])

      if village
        village.update(attributes)
        village.reload
      else
        village = find_or_create_village(attributes)
      end
    end

    def find_district(code, province_id = nil)
      District.find_by(code: code.rjust(6, '0'), province_id: province_id) ||
        District.find_by(code: code)
    end

    def find_or_create_district(attributes)
      districts = District.where(name: attributes[:name], province_id: province_id)

      if districts.count == 1
        districts.last.update(attributes)
        districts.last.reload
      elsif districts.count.zero?
        District.create(attributes)
      else
        raise StandardError, "This is an error"
      end
    end

    def find_commune(code, district_id = nil)
      Commune.find_by(code: code.rjust(6, '0'), district_id: district_id) ||
        Commune.find_by(code: code)
    end

    def find_or_create_commune(attributes)
      communes = Commune.where(name_kh: attributes[:name_kh], name_en: attributes[:name_en])

      case communes.count
      when 1
        communes.last.update(attributes)
        communes.last.reload
      when 0
        Commune.create(attributes)
      else
        matching_communes = communes.select { |commune| commune.code.to_s.rjust(6, '0') == attributes[:code] && commune.district_id == attributes[:district_id] }
        if matching_communes.count == 1
          matching_communes.first.update(attributes)
          matching_communes.first.reload
        elsif matching_communes.empty?
          Commune.create(attributes)
        else
          raise StandardError, "This is an error"
        end
      end
    end

    def find_village(code, commune_id = nil)
      Village.find_by(code: code.rjust(8, '0'), commune_id: commune_id) ||
        Village.find_by(code: code)
    end

    def find_or_create_village(attributes)
      villages = Village.where(name_kh: attributes[:name_kh], name_en: attributes[:name_en])

      case villages.count
      when 1
        villages.last.update(attributes)
        villages.last.reload
      when 0
        Village.create(attributes)
      else
        code = attributes[:code]
        filtered_villages = if code.length == 7
          villages.where("code LIKE ?", "#{code[0]}%")
        else
          villages.where("code LIKE ?", "#{code[0..1]}%")
        end

        if filtered_villages.count > 1
          Village.create(attributes)
        else
          village = filtered_villages.first
          village&.update(attributes)
          village&.reload
        end
      end
    end
  end
end
