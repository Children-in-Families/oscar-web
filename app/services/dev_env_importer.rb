module DevEnvImporter
  class Import
    attr_accessor :path, :headers, :workbook, :workbook_second_row

    def initialize(path='lib/devdata/dev_tenant.xlsx')
      @path       = path
      @workbook   = Roo::Excelx.new(path)
      @workbook_second_row = 2
    end

    def import_all
      sheets = ['users', 'families', 'clients']
      # sheets = ['clients']

      sheets.each do |sheet_name|
        @headers = Hash.new
        sheet_index = workbook.sheets.index(sheet_name)
        workbook.default_sheet = workbook.sheets[sheet_index]
        workbook.row(1).each_with_index { |header, i| headers[header] = i }
        self.send(sheet_name.to_sym)
      end
    end

    def users
      user_password = "123456789" # fixed for dev environment
      (workbook_second_row..workbook.last_row).each do |row_index|
        new_user = {}
        new_user['first_name']      = workbook.row(row_index)[headers['First Name']]
        new_user['last_name']       = workbook.row(row_index)[headers['Last Name']]
        new_user['gender']          = workbook.row(row_index)[headers['*Gender']]
        new_user['email']           = workbook.row(row_index)[headers['*Email']]
        new_user['password']        = user_password
        new_user['roles']           = workbook.row(row_index)[headers['*Permission Level']].downcase
        manager_name                = workbook.row(row_index)[headers['Manager']] || ''
        new_user['manager_id']      = User.find_by(first_name: manager_name).try(:id) unless new_user['roles'].include?("manager")
        new_user['manager_ids']     = [new_user['manager_id']]

        User.create(new_user)
      end
    end

    def families
      (workbook_second_row..workbook.last_row).each do |row_index|
        new_family                = {}
        new_family['name']        = workbook.row(row_index)[headers['*Name']]
        new_family['family_type'] = workbook.row(row_index)[headers['*Family Type']]
        new_family['status']      = workbook.row(row_index)[headers['*Family Status']]

        Family.create(new_family)
      end
    end

    def clients
      (workbook_second_row..3).each do |row_index|
        new_client                        = {}
        new_client['given_name']          = workbook.row(row_index)[headers['Given Name (English)']]
        new_client['family_name']         = workbook.row(row_index)[headers['Family Name (English)']]
        new_client['local_given_name']    = workbook.row(row_index)[headers['Given Name (Khmer)']]
        new_client['local_family_name']   = workbook.row(row_index)[headers['Family Name (Khmer)']]
        new_client['gender']              = workbook.row(row_index)[headers['* Gender']]
        new_client['date_of_birth']       = workbook.row(row_index)[headers['Date of Birth']]
        new_client['referral_source_id']  = find_referral_source(workbook.row(row_index)[headers['* Referral Source']])
        new_client['referral_source_category_id'] = find_referral_source(workbook.row(row_index)[headers['*Referral Category']])
        new_client['name_of_referee']     = workbook.row(row_index)[headers['* Name of Referee']]
        received_by_name                  = workbook.row(row_index)[headers['* Referral Received By']]
        new_client['received_by_id']      = User.find_by(first_name: received_by_name).try(:id)
        new_client['initial_referral_date']= workbook.row(row_index)[headers['* Initial Referral Date']]
        followed_up_by_name               = workbook.row(row_index)[headers['First Follow-Up By']]
        new_client['followed_up_by_id']   = User.find_by(first_name: followed_up_by_name).try(:id)
        new_client['follow_up_date']      = workbook.row(row_index)[headers['First Follow-Up Date']]
        province_name                     = workbook.row(row_index)[headers['Current Province']]
        new_client['province_id']         = find_province(province_name)
        case_worker_name                  = workbook.row(row_index)[headers['* Case Worker / Staff']]
        new_client['user_id']             = User.find_by(first_name: case_worker_name).try(:id)
        new_client['user_ids']            = [new_client['user_id']]

        client = Client.create(new_client)

        # binding.pry

        family_name   = workbook.row(row_index)[headers['Family Name']]
        family        = find_family(family_name)

        if family.present?
          family.children << client.id
          family.save
        end

        # puts "---"
        # puts "Given Name: #{new_client['given_name']}"
        # puts "Family Name: #{new_client['family_name']}"
        # puts "Khmer Given Name: #{new_client['local_given_name']}"
        # puts "Khmer Family Name: #{new_client['local_family_name']}"
        # puts "Date of Birth: #{new_client['date_of_birth']}"
        # puts "Referral Source ID: #{new_client['referral_source_id']}"
        # puts "Received by Name: #{received_by_name}"
        # puts "Followed Up by Name: #{followed_up_by_name}"
        # puts "Received By ID: #{new_client['received_by_id']}"
        # puts "Followed Up By ID: #{new_client['followed_up_by_id']}"
        # puts "Province Name: #{province_name}"
        # puts "Province ID: #{new_client['province_id']}"
        # puts "Case Worker Name: #{case_worker_name}"
        # puts "User ID: #{new_client['user_id']}"
        # puts "Family Name: #{family_name}"
        # puts "Family Obj: #{family}"
        # puts "---"
      end
    end

    private

    def find_referral_source(name)
      referral_source = ReferralSource.find_by(name_en: name)
      referral_source.try(:id)
    end

    def find_province(name)
      province = Province.find_by(name: name)
      province.try(:id)
    end

    def find_family(name)
      Family.find_by(name: name)
    end

    # def find_or_create_user(user_data)
    #   user_name = user_data.split(' ')
    #   User.find_or_create_by!(last_name: user_name.first) do |user|
    #     user.first_name = user_name.last
    #     user.gender     = 'other'
    #     user.email      = FFaker::Internet.email
    #     user.password   = password
    #     user.roles      = 'case worker'
    #   end
    # end

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
