module CvcdImporter
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = 'vendor/data/cvcd.xlsx')
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

      users.each do |user|
        user = User.new(user)
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
      headers =['given_name', 'family_name', 'local_given_name', 'local_family_name', 'gender', 'date_of_birth', 'referral_source_category_id', 'received_by_id', 'initial_referral_date', 'followed_up_by_id', 'follow_up_date', 'telephone_number', 'district_id', 'commune_id', 'house_number', 'village_id', 'school_name', 'school_grade', 'main_school_contact', 'birth_province_id', 'donor_id', 'code', 'user_ids']

      (2..sheet.last_row).each_with_index do |row_index, index|
        data       = sheet.row(row_index)
        data[4]    = data[4].squish.downcase
        data[5]    = format_date_of_birth(data[5])
        data[6]    = find_referral_source(data[6].squish)
        data[7]    = data[7].present? ? find_or_create_user(data[7].squish).id : nil
        data[9]    = data[9].present? ? find_or_create_user(data[9].squish).id : nil
        data[10]   = format_date_of_birth(data[10])
        data[11]   = data[11].to_s
        data[12]   = data[12].present? ? find_district(data[12]) : nil
        data[13]   = data[13].present? ? find_commune(data[13].squish) : nil
        data[15]   = data[15].present? ? find_village(data[15]) : nil
        data[17]   = check_nil_cell(data[17])[/^\d{1,2}/] ? check_nil_cell(data[17])[/^\d{1,2}/] : check_nil_cell(data[17])
        if data[19].present?
          data[19]   = data[19].split('/').last.squish
          data[19]   = find_province(data[19].squish)
        else
          nil
        end
        data[20]   = find_donor(data[20])
        data[22]   = find_user(data[22])
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
    end

    def find_or_create_user(user_data)
      user_name = user_data.split(' ')
      User.find_or_create_by!(last_name: user_name.first) do |user|
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

    def check_nil_cell(cell)
      cell.nil? ? '' : cell.to_s.squish
    end

    def find_donor(name)
      donors = Donor.where("name ilike ?", "%#{name}")
      begin
        donors.first.id
      rescue NoMethodError => e
        if Rails.env == 'development'
          binding.pry
        else
          Rails.logger.debug e
        end
      end
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

    def find_referral_source(name)
      referralsources = ReferralSource.where("name_en ilike?","%#{name}")
      begin
        referralsources.first.id
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

    def find_user(userid)
      users = User.where('id IN (?)', "#{userid}")
      begin
        users.first.id
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
