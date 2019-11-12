module DevEnvImporter
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = 'lib/devdata/dev_tenant.xlsx')
      @path       = path
      @sheet_name = sheet_name
      @workbook   = Roo::Excelx.new(path)

      sheet_index = workbook.sheets.index(sheet_name)
      workbook.default_sheet = workbook.sheets[sheet_index]
      sheet_header
    end

    def sheet_header
      @headers = Hash.new
      workbook.row(1).each_with_index { |header, i|
        headers[header] = i
      }
    end

    def workbook
      @workbook
    end

    def users
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        first_name      = workbook.row(row)[headers['First Name']]
        last_name       = workbook.row(row)[headers['Last Name']]
        gender          = workbook.row(row)[headers['*Gender']]
        email           = workbook.row(row)[headers['*Email']]
        password        = "123456789"
        roles           = workbook.row(row)[headers['*Permission Level']].downcase
        manager_name    = workbook.row(row)[headers['Manager']] || ''
        manager_ids      = User.find_by(first_name: manager_name).try(:id)

        User.create(first_name: first_name, last_name: last_name, gender: gender, email: email, password: password, roles: roles, manager_ids: manager_ids)
      end
    end

    def families
      headers   = ['name', 'code', 'family_type', 'status']
      families  = []
      sheet     = workbook.sheet(@sheet_name)

      (2..sheet.last_row).each_with_index do |row_index, index|
        data       = sheet.row(row_index)
        data[0]    = check_nil_cell(data[0])
        data[1]    = check_nil_cell(data[1])
        data[2]    = check_nil_cell(data[2])
        data[3]    = check_nil_cell(data[3])

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

      Family.create!(families)
    end

    def clients
      clients     = []
      sheet       = workbook.sheet(@sheet_name)

      (2..sheet.last_row).each_with_index do |row_index, index|
        given_name          = sheet.row(row_index)[headers['Given Name (English)']]
        family_name         = sheet.row(row_index)[headers['Family Name (English)']]
        local_given_name    = sheet.row(row_index)[headers['Given Name (Khmer)']]
        local_family_name   = sheet.row(row_index)[headers['Family Name (Khmer)']]
        gender              = sheet.row(row_index)[headers['* Gender']]
        date_of_birth       = sheet.row(row_index)[headers['Date of Birth']]
        # referral_source_category_id = find_referral_source(data[6].squish)
        referral_source_id  = find_referral_source(sheet.row(row_index)[headers['* Referral Source']])
        name_of_referee     = sheet.row(row_index)[headers['* Name of Referee']]
        received_by_id      = find_or_create_user(sheet.row(row_index)[headers['* Referral Received By']]).id
        initial_referral_date =  sheet.row(row_index)[headers['* Initial Referral Date']]
        followed_up_by_id   = find_or_create_user(sheet.row(row_index)[headers['First Follow-Up By']]).id
        follow_up_date      = sheet.row(row_index)[headers['First Follow-Up Date']]
        province_id         = sheet.row(row_index)[headers['Current Province']]
        district_id         = nil
        commune_id          = nil
        village_id          = nil
        code                = nil
        user_ids            = nil
        begin
          clients << { given_name: given_name, family_name: family_name, local_given_name: local_given_name, local_family_name: local_family_name, gender: gender, date_of_birth: date_of_birth, referral_source_category_id: nil, referral_source_id: referral_source_id, name_of_referee: name_of_referee, received_by_id: received_by_id, initial_referral_date: initial_referral_date, followed_up_by_id: followed_up_by_id, follow_up_date: follow_up_date, province_id: province_id  }
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
        phnom_penh = Province.find_by(name: 'ភ្នំពេញ / Phnom Penh').id
        client.province_id = phnom_penh
        client.save(validate: false)
        family = Family.find_by(code:"#{client.code}")
        if family.present?
          family.children << client.id
          family.save(validate: false)
        end
      end
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

    def password
      password   = (('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a).sample(8).join
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

    def find_user(name)
      users = User.where("first_name ilike?", "%#{name}")
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

    def find_or_create_referral_source(referral_source)
      return '' if referral_source.nil?
      ReferralSource.find_or_create_by!(name: referral_source.squish).id
    end

  end
end
