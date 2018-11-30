module WmoImporter
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = 'vendor/data/wmo.xlsx')
      @path       = path
      @sheet_name = sheet_name
      @workbook   = Roo::Excelx.new(path)
    end

    def workbook
      @workbook
    end
    
    def users
      headers = ["first_name", "last_name", "gender", "email", "password", "roles", "manager_ids"]
      users   = []
      sheet   = workbook.sheet(@sheet_name)
      managed_by     = []
      @@case_workers = []

      (2..sheet.last_row).each_with_index do |row_index, index|
        data       = sheet.row(row_index)
        data[2]    = check_gender(data[2])
        data[3]    = data[3].squish
        @@case_workers << {"#{data[4].squish}" => "#{data[3].squish}"}
        data[4]    = password
        data[5]    = data[5].downcase
        managed_by << "#{data[3]} - #{data[6]}"
        data[6]    = ''
        begin
          users << [headers, data.reject(&:nil?)].transpose.to_h
        rescue IndexError => e
          if Rails.env == 'development'
            binding.pry
          else
            Rails.logger.debug e
          end
        end
      end
      users.each do |user|
        u = User.find_by(email: user['email'])
        if u.present?
          u.update_attributes(user.except('password'))
        else
          User.create!(user)
        end
      end
      puts 'Create users one!!!!!!'

      managed_by.each do |data|
        user_email = data.split('-').first
        manager_email = data.split('-').last
        user = User.find_by(email: user_email.squish)
        manager = User.find_by(email: manager_email.squish).try(:id)
        next if manager.nil?
        user.manager_id = manager
        user.save(validate: false)
      end
      puts 'Added manager ids!!'

      Donor.create(name: 'SCI', code: '03601351')
      puts 'Added donor'
    end

    def password
      password   = (('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a).sample(8).join
    end

    def families
      families = []
      sheet    = workbook.sheet(@sheet_name)
      headers  = ['name', 'code', 'family_type']

      (2..sheet.last_row).each_with_index do |row_index, index|
        data    = sheet.row(row_index)
        data [0]  = data[0].squish
        data [1]  = data[1].squish
        data [2]  = ''
        begin
          families << [headers, data.reject(&:nil?)].transpose.to_h
        rescue IndexError => e
          if Rails.env == 'development'
            binding.pry
          else
            Rails.logger.debug e
          end
        end
      end

      families.each do |data|
        family = Family.new(data)
        family.save(validate: false)
      end
      puts 'Create families done!!!!!!'
    end

    def clients
      clients     = []
      sheet       = workbook.sheet(@sheet_name)
      has_family  = []

      headers =['local_given_name', 'local_family_name', 'gender', 'date_of_birth', 'school_name', 'school_grade', 
                'birth_province_id', 'province_id', 'district_id' ,'commune_id', 'village_id', 'follow_up_date', 
                'initial_referral_date', 'referral_source_id', 'referral_phone', 'has_been_in_orphanage', 
                'has_been_in_government_care', 'relevant_referral_information', 
                'kid_id', 'family_ids', 'donor_ids', 'user_ids', 'country_origin']

      (2..sheet.last_row).each_with_index do |row_index, index|
        data       = sheet.row(row_index)
        data[0]    = data[0].squish
        data[1]    = data[1].squish
        data[2]    = check_gender(data[2])
        data[3]    = format_date(data[3])
        data[4]    = check_nil_cell(data[4])
        data[5]    = check_nil_cell(data[5])
        Organization.switch_to 'shared'
        data[6]    = Province.find_by('name ilike ?', "%#{data[6].squish}%").try(:id) || ''
        Organization.switch_to 'wmo'
        data[7]    = Province.find_by('name ilike ?', "%#{data[7].squish}%").try(:id) || ''
        data[8]    = find_district(data[7], data[8])
        data[9]    = find_commune(data[8], data[9])
        data[10]   = find_village(data[9], data[10])
        data[11]   = format_date(data[11])
        data[12]   = format_date(data[12])
        data[13]   = find_or_create_referral_source(data[13])
        data[14]   = check_nil_cell(data[14])
        data[15]   = find_boolean_value(data[15])
        data[16]   = find_boolean_value(data[16])
        data[17]   = check_nil_cell(data[17])
        data[18]   = check_nil_cell(data[18])
        has_family << "#{data[18]} , #{data[19]}"
        data[19]   = ''
        data[20]   = Donor.find_by(name: 'SCI').try(:id)
        data[21]   = find_case_worker(data[21].squish) 
        data[22]   = 'cambodia'

        data       = data.map{|d| d == 'N/A' ? d = '' : d }
        begin
          clients << [headers, data].transpose.to_h
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

      has_family.each do |family|
        client = Client.find_by(kid_id: family.split(',').first.squish)
        family = Family.find_by(code: family.split(',').last.squish)
        family.children << client.id
        family.save(validate: false)
      end
      puts 'assign family'

    end

    def find_case_worker(case_worker_id)
      user = nil
      user = @@case_workers.map do |case_worker|
        User.find_by(email: case_worker[case_worker_id]).try(:id)
      end
      user.reject(&:nil?)
    end
   
    def find_village(commune_id, village_name)
      return '' if village_name.nil? || commune_id.blank?
      village = Commune.find(commune_id).villages.find_by('name_kh ilike ?',  "%#{village_name.squish}%").try(:id)
    end

    def find_commune(district_id, commune_name)
      return '' if commune_name.nil? || district_id.blank?
      commune = District.find(district_id).communes.find_by('name_kh ilike ?', "%#{commune_name.squish}%").try(:id)
    end

    def find_district(province_id, district_name)
      return '' if district_name.nil? || province_id.blank?
      district = Province.find(province_id).districts.find_by('name ilike ?', "%#{district_name.squish}%").try(:id)
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

    def format_date(value)
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
