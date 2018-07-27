module FlameImporter
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = 'vendor/data/flame.xlsx')
      @path       = path
      @sheet_name = sheet_name
      @workbook   = Roo::Excelx.new(path)
    end

    def workbook
      @workbook
    end

    def users
      headers  = ["first_name", "last_name", "email", "password", "roles", "manager_ids"]
      users    = []
      sheet    = workbook.sheet(@sheet_name)

      (2..sheet.last_row).each_with_index do |row_index, index|
        data       = sheet.row(row_index)
        data[0]    = check_nil_cell(data[0])
        data[1]    = check_nil_cell(data[1])
        data[2]    = check_nil_cell(data[2])
        data[3]    = password
        data[4]    = data[4].try(:downcase)
        data[5]    = ''

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

      User.create!(users)
      puts 'Create users done!!!!!!'

      User.all.each do |user|
        next if user.first_name == 'Vandeth' || user.first_name == 'Maria'
        id = User.find_by(first_name: 'Maria')
        user.update_attributes(manager_id: id)
      end

      puts 'Add managers done!!!!!!'
    end

    def password
      password   = (('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a).sample(8).join
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
      puts 'Create families done!!!'
    end

    def clients
      clients     = []
      sheet       = workbook.sheet(@sheet_name)

      headers =['given_name', 'family_name', 'local_given_name', 'local_family_name', 'gender', 'date_of_birth', 'referral_source_id', 'name_of_referee', 'received_by_id', 'initial_referral_date', 'user_ids', 'live_with', 'telephone_number', 'province_id', 'district_id', 'commune', 'village', 'school_name', 'school_grade', 'rated_for_id_poor', 'has_been_in_orphanage', 'has_been_in_government_care', 'country_origin']

      (2..sheet.last_row).each_with_index do |row_index, index|
        data       = sheet.row(row_index)
        data[0]    = data[0].squish
        data[1]    = data[1].squish
        data[2]    = data[2].squish
        data[3]    = data[3].squish
        data[4]    = data[4].downcase == 'male' ? 'male' : 'female'
        data[5]    = format_date_of_birth(data[5])
        data[6]    = find_referral_source(data[6])
        data[7]    = check_nil_cell(data[7])

        data[8]    = find_referral_received_by(data[8])

        data[9]    = format_date_of_birth(data[9])
        data[10]   = find_case_worker(data[10])
        data[11]   = check_nil_cell(data[11])
        data[12]   = check_nil_cell(data[12])

        data[13]   = find_province(data[13])
        data[14]   = find_district(data[14])
        data[15]   = check_nil_cell(data[15])
        data[16]   = check_nil_cell(data[16])
        data[17]   = check_nil_cell(data[17])
        data[18]   = check_nil_cell(data[18])

        #need to recheck id_poor
        data[19]   = check_nil_cell(data[19])

        data[20]   = find_boolean_value(data[20])
        data[21]   = find_boolean_value(data[21])
        data[22]   = 'cambodia'

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

    def find_case_worker(name)
      name = name.split(' ').first
      case_worker = User.where("first_name iLike ?", "%#{name.squish}")
      id = case_worker.first.try(:id)
    end

    def find_referral_received_by(name)
      name = name.split(' ').first
      user = User.where("first_name iLike ?", "%#{name.squish}")
      if user.present?
        user = user.first
      else
        user = User.create!(first_name: name, email: FFaker::Internet.email, password: password)
      end
      user.try(:id)
    end

    def find_boolean_value(cell)
      cell.nil? ? '' : cell.to_s.squish
      (cell == 'Yes' || cell == 'yes') ? true : false
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
