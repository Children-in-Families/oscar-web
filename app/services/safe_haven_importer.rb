module SafeHavenImporter
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = 'vendor/data/haven.xlsx')
      @path       = path
      @sheet_name = sheet_name
      @workbook   = Roo::Excelx.new(path)
    end

    def workbook
      @workbook
    end

    def users
      headers = ["first_name", "last_name", "email", "password", "roles"]
      users = []
      sheet = workbook.sheet(@sheet_name)

      (2..sheet.last_row).each_with_index do |row_index, index|
        data       = sheet.row(row_index)
        data[3]    = password
        data[4]    = data[4].present? ? data[4].try(:downcase).squish : 'case worker'
        begin
          users << [headers, data.reject(&:blank?)].transpose.to_h
        rescue IndexError => e
          if Rails.env == 'development'
            binding.pry
          else
            Rails.logger.debug e
          end
        end
      end

      User.create!(users)
      puts 'Create users one!!!!!!'
    end

    def password
      password   = (('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a).sample(8).join
    end

    def clients
      clients     = []
      sheet       = workbook.sheet(@sheet_name)

      headers =['given_name', 'family_name', 'gender', 'date_of_birth', 'referral_source_id', 'name_of_referee', 'initial_referral_date', 'live_with', 'telephone_number', 'province_id', 'district_id', 'commune', 'village', 'agency_ids', 'code', 'user_ids']

      (2..sheet.last_row).each_with_index do |row_index, index|
        data       = sheet.row(row_index)
        data[0]    = data[0].squish
        data[1]    = data[1].squish
        data[2]    = data[2].downcase.include?('m') ? 'male' : 'female'
        data[3]    = format_date_of_birth(data[3])

        data[4]    = find_referral_source(data[4])

        data[5]    = check_nil_cell(data[5])
        data[6]    = format_date_of_birth(data[6])
        data[7]    = check_nil_cell(data[7])
        data[8]    = check_nil_cell(data[8])

        #current_province
        data[9]    = find_province(data[9])

        #district
        data[10]   = find_district(data[10])

        data[11]   = check_nil_cell(data[11])
        data[12]   = check_nil_cell(data[12])

        #agency
        data[13]   = find_agency(data[13])

        data[14]   = check_nil_cell(data[14])

        #case_worker
        data[15]   = find_users

        data       = data.map{|d| d == 'N/A' ? d = '' : d }

        begin
          clients << [headers, data.reject(&:nil?)].transpose.to_h
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

    def find_users
      emails = [ 'pheakdey@safehavenkhmer.org', 'pheary@safehavenkhmer.org', 'phearom@safehavenkhmer.org', 'leakna@safehavenkhmer.org', 'Chamreoun@safehavenkhmer.org', 'kosal@safehavenkhmer.org', 'long@safehavenkhmer.org' ]
      users = User.where('email IN (?)', emails).ids
    end

    def find_agency(name)
      return '' unless name.present?
      agency = Agency.where("name ilike ?", "%#{name.squish}")
      if agency.present?
        agency = agency.first
      else
        agency = Agency.find_or_create_by!(name: name.squish)
      end
      agency.try(:id)
    end

    def find_referral_source(name)
      return '' unless name.present?
      referral_source = ReferralSource.where("name ilike ?", "%#{name.squish.squish}")
      if referral_source.any?
        referral_source = referral_source.first
      else
        referral_source = ReferralSource.find_or_create_by!(name: name.squish)
      end
      referral_source.try(:id)
    end

    def find_district(name)
      return '' unless name.present?
      districts = District.where("name ilike ?", "%#{name.squish}")
      district = districts.select{|d| d.name.gsub(/.*\//, '').squish == name }
      begin
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
      return '' unless name.present?
      provinces = Province.where("name ilike ?", "%#{name.squish}")
      province  = provinces.select{|d| d.name.gsub(/.*\//, '').squish == name.squish }
      begin
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
      return '' unless value.present?
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
