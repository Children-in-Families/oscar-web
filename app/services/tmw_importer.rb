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

    def clients
      clients     = []
      sheet       = workbook.sheet(@sheet_name)

      headers =['given_name', 'family_name', 'local_given_name', 'local_family_name', 'gender', 'date_of_birth', 'referral_source_id', 'name_of_referee', 'referral_phone', 'received_by_id', 'initial_referral_date', 'followed_up_by_id', 'follow_up_date', 'user_ids', 'live_with', 'telephone_number', 'province_id', 'district_id', 'commune_id', 'house_number', 'street_number', 'village_id', 'school_name', 'school_grade', 'main_school_contact', 'agency_ids', 'has_been_in_government_care', 'country_origin']

      (6..sheet.last_row).each_with_index do |row_index, index|
        data       = sheet.row(row_index)
        data[0]    = data[0].squish
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
        data[9]    = find_or_create_user(data[9])

        data[10]   = format_date_of_birth(data[10])

        # first_follow_up_by
        data[11]   = find_or_create_user(data[11])

        data[12]   = format_date_of_birth(data[12])
        # case_workers
        data[13]   = find_caseworker(data[13])
        data[14]   = check_nil_cell(data[14])
        data[15]   = check_nil_cell(data[15])

        # district
        data[17] = find_district(data[17])
        # current_province
        data[16] = find_province(data[17])
        # commune
        data[18] = find_commune(data[17], data[18])

        data[19]   = check_nil_cell(data[20])
        data[20]   = check_nil_cell(data[21])
        #village
        data[21]   = find_village(data[18], data[21])

        data[22]   = check_nil_cell(data[22])
        # school_grade
        data[23]   = check_nil_cell(data[23])
        data[24]   = check_nil_cell(data[24])

        # agencies
        data[25]   = find_agency(data[25])
        data[26]   = find_boolean_value(data[26])
        data[27]   = 'cambodia'
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

    def find_agency(name)
      return '' if name.nil?
      agency = Agency.find_or_create_by!(name: name.squish)
      [agency.try(:id)]
    end

    def find_village(commune_id, village_name)
      return '' if village_name.nil? || commune_id.blank?
      Commune.find(commune_id).villages.find_by(name_en: village_name.squish).try(:id)
    end

    def find_commune(district_id, commune_name)
      return '' if commune_name.nil? || district_id.blank?
      District.find(district_id).communes.find_by('name_en ilike ?', "%#{commune_name.squish}%").try(:id)
    end

    def find_province(district_id)
      return '' if district_id.blank?
      District.find(district_id).province.id
    end

    def find_district(name)
      return '' if name.blank?
      District.find_by('name ilike ?', "%#{name.squish}%").try(:id) || ''
    end

    def find_or_create_user(user_data)
      return '' if user_data.nil?
      user_name = user_data.split(' ')
      user = User.find_or_create_by!(first_name: user_name.first) do |user|
        user.last_name  = user_name.last.squish if user_name.last.present?
        user.email      = FFaker::Internet.email
        user.password   = password
      end
      user.try(:id)
    end

    def find_caseworker(caseworker)
      return '' if caseworker.nil?
      ids = []
      caseworkers = caseworker.gsub('Team', '').split('&').map{ |c| c.squish }
      caseworkers.each do |case_worker|
        ids << User.find_by('first_name ilike ?', "%#{case_worker}%").try(:id)
      end
      ids
    end

    def find_or_create_referral_source(referral_source)
      return '' if referral_source.nil?
      ReferralSource.find_or_create_by!(name: referral_source.squish).id
    end

    def find_boolean_value(cell)
      return '' if cell.nil?
      (cell.squish.downcase == 'yes') ? true : false
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

    def format_date_of_birth(value)
      return '' if value.nil?
      first_regex  = /\A\d{2}\/\d{2}\/\d{2}\z/
      second_regex = /\A\d{4}\z/
      value = value.to_s
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
