module MslImporter
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = 'vendor/data/msl.xlsx')
      @path       = path
      @sheet_name = sheet_name
      @workbook   = Roo::Excelx.new(path)
    end

    def workbook
      @workbook
    end

    def users
      headers = ['first_name', 'last_name', 'email', 'roles', 'password']
      users = []
      sheet = workbook.sheet(@sheet_name)
      managers = []

      (2..sheet.last_row).each_with_index do |row_index, index|
        data       = sheet.row(row_index)
        data[0]    = data[0].squish
        data[1]    = data[1].squish
        data[2]    = data[2].squish
        data[3]    = data[3].downcase.squish
        managers << "#{data[2].squish}, #{data[4].squish}"
        data[4]    = password
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

      users.each do |user|
        user = User.new(user)
        user.save(validate: false)
      end

      managers.each do |manager|
        user = User.find_by(email: manager.split(', ').first.squish)
        user.manager_id = User.create_with(email: FFaker::Internet.email, password: password).find_or_create_by(first_name:  manager.split(', ').last.squish).try(:id)
        user.save(validate: false)
      end

      puts 'Create users one!!!!!!'
    end

    def password
      password   = (('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a).sample(8).join
    end

    def clients
      clients     = []
      sheet       = workbook.sheet(@sheet_name)
      headers     = ['given_name', 'family_name', 'local_given_name', 'local_family_name', 'gender', 'date_of_birth', 'referral_source_id', 'name_of_referee', 'referral_phone', 'received_by_id', 
                    'initial_referral_date', 'followed_up_by_id', 'follow_up_date', 'user_ids', 'province_id', 'district_id', 'commune_id', 'house_number', 'street_number', 'village_id', 'school_name', 
                    'school_grade', 'birth_province_id']

      (2..sheet.last_row).each_with_index do |row_index, index|
        data       = sheet.row(row_index)
        data[4]    = data[4].squish.downcase
        data[5]    = format_date_of_birth(data[5])

        #create referral source
        data[6]    = create_referral_source(data[6])

        #received by
        data[9]    = data[9].present? ? find_or_create_user(data[9].squish).id : nil

        data[10]   = format_date_of_birth(data[10])

        #followed up by
        data[11]   = data[11].present? ? find_or_create_user(data[11].squish).id : nil
        data[12]   = format_date_of_birth(data[12])

        #user_ids
        data[13]   = data[13].present? ? [find_or_create_user(data[13].squish).id] : []

        #province_id
        data[14]   = Province.where('name ilike ?', "%#{data[14].squish}%").first.try(:id)
        data[15]   = District.where('name ilike ?', "%#{data[15].squish}%").first.try(:id)
        data[16]   = Commune.where('name_kh ilike ?', "%#{data[16].squish}%").first.try(:id)
        data[19]   = data[19].present? ? Village.where('name_kh ilike ?', "%#{data[19]}%").first.try(:id) : nil
        data[22]   = Province.where('name ilike ?', "%#{data[22].squish}%").first.try(:id)

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
        if client.given_name == 'Sreythy'
          client.has_been_in_orphanage = false
          client.has_been_in_government_care = false
          client.rated_for_id_poor = 'No'
          client.save(validate: false)
        end
      end
      puts 'Create clients done!!!!!!'
    end

    def create_referral_source(name)
      ReferralSource.find_or_create_by(name: name.squish).try(:id)
    end

    def find_or_create_user(user_data)
      user_name = user_data.split(' ')
      User.find_or_create_by!(first_name: user_name.last) do |user|
        user.first_name = user_name.last
        user.gender     = 'other'
        user.email      = FFaker::Internet.email
        user.password   = password
        user.roles      = 'case worker'
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

    def find_commune(name)
      communes = Commune.where("name_en ilike?","%#{name.squish}")
      commune = communes.select{|d| d.name.gsub(/.*\//, '').squish == name }
      begin
        commune.first.id
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

    def find_village(name)
      villages = Village.where("name_en ilike ?", "%#{name}")
      begin
        villages.first.id
      rescue NoMethodError => e
        if Rails.env == 'development'
          binding.pry
        else
          Rails.logger.debug e
        end
      end
    end
  end
end
