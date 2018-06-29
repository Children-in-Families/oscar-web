module MotherHeartNewClientImporter
  class Import
    attr_accessor :path, :headers, :workbook
    def initialize(sheet_name, path = 'vendor/data/New Client Data.xlsx')
      @path       = path
      @sheet_name = sheet_name
      @workbook   = Roo::Excelx.new(path)
    end

    def workbook
      @workbook
    end

    def clients
      clients               = []
      sheet                 = workbook.sheet(@sheet_name)

      headers =['given_name', 'family_name', 'local_given_name', 'local_family_name', 'gender', 'date_of_birth', 'referral_source_id', 'name_of_referee', 'referral_phone', 'received_by_id', 'initial_referral_date', 'user_ids', 'telephone_number', 'province_id', 'district_id', 'commune', 'village']
      referral_source_id    = referral_source('param').id

      (6..sheet.last_row).each_with_index do |row_index, index|
        data       = sheet.row(row_index)
        next if data[0].nil?
        data[0]    = data[0].squish
        data[1]    = data[1].squish
        data[2]    = data[2].squish
        data[3]    = data[3].squish
        data[4]    = 'female'
        data[5]    = format_date_of_birth(data[5])
        data[6]    = referral_source(data[6].squish).id
        data[7]    = check_nil_cell(data[7])
        data[8]    = check_nil_cell(data[8])
        data[9]    = find_user(data[9].squish)
        data[10]   = format_date_of_birth(data[10])
        data[11]   = [find_user(data[11].squish)]
        data[12]   = check_nil_cell(data[12])
        data[13]   = find_province(data[13].squish)
        data[14]   = find_district(data[14])
        data[15]   = check_nil_cell(data[15])
        data[16]   = check_nil_cell(data[16])

        begin
          clients << [headers, data[0..16]].transpose.to_h
        rescue IndexError => e
          if Rails.env == 'development'
            binding.pry
          else
            Rails.logger.debug e
          end
        end
      end

      clients.each do |client|
        client = Client.new(client)
        client.save(validate: false)
      end
      puts 'Create clients done!!!!!!'
    end

    def find_user(user_name)
      user_name = user_name == 'Srey Neang' ? user_name : user_name.split(' ').last
      begin
        User.find_by(first_name: user_name).id
      rescue NoMethodError => e
        binding.pry
      end
    end

    def referral_source(referral_source_name)
      ReferralSource.find_or_create_by!(name: referral_source_name)
    end

    def find_district(name)
      return nil if name.nil?
      districts = District.where("name ilike ?", "%#{name.squish}")
      district = districts.select{|d| d.name.gsub(/.*\//, '').squish == name.squish }
      begin
        return nil if district.blank?
        district.first.id
      rescue NoMethodError => e
        if Rails.env == 'development'
          binding.pry
        else
          Rails.logger.debug e
        end
      end
    end

    def find_province(name)
      provinces = Province.where("name ilike ?", "%#{name}")
      province  = provinces.select{|d| d.name.gsub(/.*\//, '').squish == name }
      begin
        return nil if province.blank?
        province.first.id
      rescue NoMethodError => e
        if Rails.env == 'development'
          binding.pry
        else
          Rails.logger.debug e
        end
      end
    end

    def format_date_of_birth(value)
      first_regex  = /\A\d{2}\/\d{2}\/\d{2}\z/
      second_regex = /\A\d{4}\z/

      if value =~ first_regex
        value  = value.split('/')
        year = "20#{value.last}"
        value  = value.shift(2)
        value  = value.push(year)
        value  = value.join('-')
      elsif value =~ second_regex
        value = "01-01-#{value}"
      end
      value
    end

    def check_nil_cell(cell)
      cell.nil? ? '' : cell.to_s.squish
    end
  end
end
