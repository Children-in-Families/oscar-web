module KomarRikreayImporter
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = 'vendor/data/komar_rikreay.xlsx')
      @path       = path
      @sheet_name = sheet_name
      @workbook   = Roo::Excelx.new(path)
    end

    def workbook
      @workbook
    end

    def users
      headers = ['first_name', 'last_name', 'email', 'password', 'roles']
      users = []
      sheet = workbook.sheet(@sheet_name)

      (2..sheet.last_row).each_with_index do |row_index, index|
        data       = sheet.row(row_index)
        data[0]    = check_nil_cell(data[0])
        data[1]    = check_nil_cell(data[1])
        data[2]    = check_nil_cell(data[2])
        data[3]    = password
        data[4]    = data[4].try(:downcase).squish
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
      puts 'Create users done!!!!!!'
    end

    def donors
      headers = ['name', 'code']
      donors  = []
      sheet   = workbook.sheet(@sheet_name)

      (2..sheet.last_row).each_with_index do |row_index, index|
        data    = sheet.row(row_index)
        data[0] = data[0].squish
        data[1] = data[1].squish

        begin
          donors << [headers, data.reject(&:blank?)].transpose.to_h
        rescue IndexError => e
          if Rails.env == 'development'
            binding.pry
          else
            Rails.logger.debug e
          end
        end
      end

      Donor.create!(donors)
      puts 'Create donors done!!!!!!'
    end

    def families
      headers   = ['name', 'code', 'case_history', 'family_type']
      families  = []
      sheet     = workbook.sheet(@sheet_name)

      (2..sheet.last_row).each_with_index do |row_index, index|
        data    = sheet.row(row_index)
        data[0] = data[1].squish + " / " + data[0].squish
        data[1] = data[2].squish
        data[2] = "#{data[4].squish} #{data[3].squish}"
        data[3] = map_family_type(data[5].squish)
        data[4] = nil
        data[5] = nil

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

      families.each do |family|
        family = Family.new(family)
        family.save(validate: false)
      end

      puts 'Create families done!!!!!!'
    end

    def clients
      clients     = []
      sheet       = workbook.sheet(@sheet_name)
      headers     = ['given_name', 'family_name', 'local_given_name', 'local_family_name', 'gender', 'date_of_birth', 'school_name', 'school_grade', 'birth_province_id', 'province_id', 'district_id', 'current_address', 'follow_up_date', 'initial_referral_date', 'referral_phone', 'has_been_in_orphanage', 'has_been_in_government_care', 'relevant_referral_information', 'kid_id', 'user_ids', 'country_origin', 'donor_ids']
      family_hash = Hash.new { |h,k| h[k] = []}

      (2..sheet.last_row).each_with_index do |row_index, index|
        data       = sheet.row(row_index)
        data[0]    = data[0].squish
        data[1]    = data[1].squish
        data[2]    = data[2].squish
        data[3]    = data[3].squish
        data[4]    = data[4].squish
        data[5]    = format_date_of_birth("#{data[5]}")
        data[6]    = data[6].squish

        #school grade
        data[7]    = check_nil_cell(data[7])
        #birth province
        data[8]    = find_province(data[8])
        #current province
        data[9]    = find_province(data[9])

        data[10]   = find_district(data[10].squish)
        data[11]   = data[11].squish
        data[12]   = format_date_of_birth("#{data[12]}")
        data[13]   = format_date_of_birth("#{data[13]}")
        data[14]   = check_nil_cell(data[14])
        data[15]   = find_boolean_value(data[15])
        data[16]   = find_boolean_value(data[16])
        data[17]   = check_nil_cell(data[17])
        data[18]   = data[18].squish

        #case workers
        data[19]   = map_case_worker(data[19].squish)
        family     = { "#{data[18]}".squish => "#{check_nil_cell(data[20])}" }
        family_hash.merge!(family)

        data[20]   = 'cambodia'

        #donor_id
        data[21]   = find_donors(data[21])

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

      family_hash.each do |kid_id, family_id|
        client = Client.find_by(kid_id: kid_id)
        family = Family.find_by(code: family_id)
        if family.present?
          family.children << client.id
          family.save(validate: false)
        end
      end
    end

    def map_case_worker(value)
      first_names = {'ACP-001' => 'Saran', 'RRR-001' =>'Kanika', 'CFE-001' => 'Boramey', 'CFE-002' => 'Satheavuth', 'CFE-004' => 'Sokrady', 'CFE-005' => 'Leakhena', 'CFE-007' => 'Sotheary' }
      user_id     = User.find_by(first_name: first_names[value]).try(:id)
    end

    def map_family_type(value)
      if value == 'Foster'
        'Long Term Foster Care'
      elsif value == 'Emergency'
        'Short Term / Emergency Foster Care'
      elsif value == 'Birth Family'
        'Birth Family (Both Parents)'
      end
    end

    def password
      password   = (('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a).sample(8).join
    end

    def find_boolean_value(cell)
      cell.nil? ? '' : cell.to_s.squish
      (cell == 'Yes' || cell == 'yes') ? true : false
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

    def find_donors(codes)
      return [] if codes.blank?
      Donor.where(code: codes.split(', ')).ids
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
