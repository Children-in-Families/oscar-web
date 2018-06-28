module AuscamImporter
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = 'vendor/data/auscam.xlsx')
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
      outreach    = outreach_referral_source.id
      mother      = mother_referral_source.id
      outreach_id = create_user_outreach.id
      clients     = []
      sheet       = workbook.sheet(@sheet_name)

      headers =['given_name', 'family_name', 'local_given_name', 'local_family_name', 'gender', 'date_of_birth', 'referral_source_id', 'name_of_referee', 'received_by_id', 'followed_up_by_id', 'follow_up_date', 'user_ids', 'live_with', 'telephone_number', 'province_id', 'district_id', 'commune', 'house_number', 'street_number', 'village', 'school_name', 'school_grade', 'birth_province_id']

      (6..sheet.last_row).each_with_index do |row_index, index|
        data       = sheet.row(row_index)
        data[4]    = data[4].squish.downcase
        data[5]    = format_date_of_birth(data[5])
        data[6]    = data[6][/Outreach/i] ? outreach : mother
        data[8]    = outreach_id
        data[9]    = find_or_create_user(data[9].squish).id
        data[10]   = format_date_of_birth(data[10])
        data[11]   = [find_or_create_user(data[11].squish).id]

        data[14]   = Province.find_by(name: 'ភ្នំពេញ / Phnom Penh').id
        data[15]   = find_district(data[15])
        data[21]   = check_nil_cell(data[21])[/^\d{1,2}/] ? check_nil_cell(data[21])[/^\d{1,2}/] : check_nil_cell(data[21])
        data[22]   = data[22].split('/').last.squish
        data[22]   = find_province(data[22].squish)
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

    def find_or_create_user(user_data)
      user_name = user_data.split(' ')
      User.find_or_create_by!(last_name: user_name.first) do |user|
        user.first_name = user_name.last
        user.email      = FFaker::Internet.email
        user.password   = password
        user.roles      = 'case worker'
      end
    end

    def create_user_outreach
      User.create!(first_name: 'Outreach', email: 'outreach@example.com', password: password, roles: 'case worker')
    end

    def outreach_referral_source
      ReferralSource.find_or_create_by!(name: 'Outreach')
    end

    def mother_referral_source
      ReferralSource.find_or_create_by!(name: "Mother's Heart")
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
