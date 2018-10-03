module TmwImporter
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = 'vendor/data/tmw.xlsx')
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

      (3..sheet.last_row).each_with_index do |row_index, index|
        data       = sheet.row(row_index)
        data[3]    = password
        data[4]    = data[4].downcase
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

    agency_info = []
    def clients
      clients     = []
      sheet       = workbook.sheet(@sheet_name)

      headers =['given_name', 'family_name', 'local_given_name', 'local_family_name', 'gender', 'date_of_birth', 'referral_source_id', 'name_of_referee', 'referral_phone', 'received_by_id', 'initial_referral_date', 'followed_up_by_id', 'follow_up_date', 'user_ids', 'live_with', 'telephone_number', 'province_id', 'district_id', 'commune', 'house_number', 'street_number', 'village', 'school_name', 'school_grade', 'main_school_contact', 'birth_province_id', 'country_origin', 'has_been_in_government_care']

      (6..sheet.last_row).each_with_index do |row_index, index|
        data       = sheet.row(row_index)
        data[1]    = check_nil_cell(data[1])
        data[2]    = check_nil_cell(data[2])
        data[3]    = check_nil_cell(data[3])
        data[4]    = check_gender(data[4])
        data[5]    = format_date_of_birth(data[5])
        # referral_source
        data[6]    = find_or_create_referral_source(data[6])
        data[7]    = check_nil_cell(data[7])
        data[8]    = check_nil_cell(data[8])

        # referral_receive_by
        data[9]    =

        data[10]   = format_date_of_birth(data[10])

        # first_follow_up_by
        data[11]

        data[12]   = format_date_of_birth(data[12])
        # case_workers
        data[13]   = find_caseworker(data[13])
        data[14]   = check_nil_cell(data[14])
        data[15]   = check_nil_cell(data[15])

        # current_province
        data[17]
        # district
        data[18]
        # commune
        data[19]

        data[20]   = check_nil_cell(data[20])
        data[21]   = check_nil_cell(data[21])
        data[22]   = check_nil_cell(data[22])
        data[23]   = check_nil_cell(data[23])
        # school_grade
        data[24]   = check_nil_cell(data[24])
        data[25]   = check_nil_cell(data[25])

        # client_birth_province
        data[26]

        # agencies
        if data[27].present?
          agency_info << "#{data[0] - data[27]}"
        end
        data[27]   = 'cambodia'
        data[28]   = find_boolean_value(data[28])
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

      add_agency_to_client

      puts 'Create clients done!!!!!!'
    end

    def add_agency_to_client
      agency_info.each do |data|
        given_name  = data.split('-').first.squish
        agency_name = data.split('-').last.squish
        client      = Client.find_by(given_name: given_name)
        agency_id   = Agency.find_or_create_by!(name: agency_name).id
        AgencyClient.create(client_id: client.id, agency_id: agency_id)
      end
    end

    def find_caseworker(caseworker)
      return '' if caseworker.nil?
      ids = []
      caseworkers = caseworker.split('&').map{ |c| c.squish }
      caseworkers.each do |case_worker|
        ids << User.where('first_name ilike ?', "%#{case_worker}%")
      end
      ids
    end

    def find_or_create_referral_source(referral_source)
      return '' if referral_source.nil?
      ReferralSource.find_or_create_by!(name: referral_source.squish).id
    end

    def find_boolean_value(cell)
      cell.nil? ? '' : cell.to_s.squish
      (cell.downcase == 'yes') ? true : false
    end

    def check_gender(gender)
      return '' if gender.nil?
      gender = gender.downcase
      if ['male', 'm'].include?(gender)
        'male'
      else
        'female'
      end
    end

    def find_district(name)
      districts = District.where("name ilike ?", "%#{name}")
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
      provinces = Province.where("name ilike ?", "%#{name}")
      province  = provinces.select{|d| d.name.gsub(/.*\//, '').squish == name }
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
