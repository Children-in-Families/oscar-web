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
          attributes['code'] = values[1].squish.to_s.rjust(4, '0')
          attributes['province_id'] = province_id

          district = District.find_by(code: attributes['code'])
          district = district || District.find_by(code: attributes['code'].rjust(6, '0'))
          district = district || District.find_by(code: attributes['code'], province_id: province_id)
          district = district || District.find_by(code: attributes['code'].rjust(6, '0'), province_id: province_id)

          if district
            district.update_attributes(attributes)
            district = district.reload
          else
            # find existing districts
            districts = District.where(name: attributes['name'])
            if districts.count == 1
              districts.last.update_attributes(attributes)
              district = districts.last.reload
            elsif districts.count.zero?
              district = District.find_or_create_by(attributes)
            else
              binding.pry
            end
          end

          district_id = district&.id
          pp district_id
        elsif row_type.strip == "ឃុំ" || row_type.strip == "សង្កាត់"
          data = values[1..3].map(&:squish)
          data << district_id

          fields << 'district_id'
          attributes = [fields, data].transpose.to_h

          commune = Commune.find_by(code: attributes['code'])
          commune = commune || Commune.find_by(code: attributes['code'].rjust(6, '0'))
          commune = commune || Commune.find_by(code: attributes['code'].rjust(6, '0'), district_id: district_id)
          commune = commune || Commune.find_by(code: attributes['code'], district_id: district_id)

          attributes['code'] = attributes['code'].rjust(6, '0')
          if commune
            commune.update_attributes(attributes)
            commune = commune.reload
          else
            # find existing communes
            communes = Commune.where(name_kh: attributes['name_kh'], name_kh: attributes['name_en'])
            if communes.count == 1
              communes.last.update_attributes(attributes)
              commune = communes.last.reload
            elsif communes.count.zero?
              commune = Commune.find_or_create_by(attributes)
            else
              binding.pry
            end
          end

          commune_id = commune&.id
        else
          data = values[1..3].map(&:squish)
          data << commune_id
          fields << 'commune_id'
          attributes = [fields, data].transpose.to_h

          village = Village.find_by(code: attributes['code'])
          village = village || Village.find_by(code: attributes['code'].rjust(8, '0'))
          village = village || Village.find_by(code: attributes['code'].rjust(8, '0'), commune_id: commune_id)
          village = village || Village.find_by(code: attributes['code'], commune_id: commune_id)

          attributes['code'] = attributes['code'].rjust(8, '0')
          if village
            village.update_attributes(attributes)
            village = village.reload
          else
            # find existing villages
            villages = Village.where(name_kh: attributes['name_kh'], name_kh: attributes['name_en'])
            if villages.count == 1
              villages.last.update_attributes(attributes)
              village = villages.last.reload
            elsif villages.count.zero?
              village = Village.find_or_create_by(attributes)
            else
              binding.pry
            end
          end
        end
      end

      puts "Done #{path} !!!"
    end
  end
end
