module AjlImporter
  class Import
    attr_accessor :path, :headers, :workbook, :workbook_second_row

    def initialize(path='lib/devdata/ajl.xlsx')
      @path       = path
      @workbook   = Roo::Excelx.new(path)
      @headers    = {}
      @workbook_second_row = 2
    end

    def import_all
      sheets = ['users', 'families', 'donors', 'clients']

      sheets.each do |sheet_name|
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
        new_user['email']           = workbook.row(row_index)[headers['*Email']]
        new_user['password']        = user_password
        new_user['roles']           = workbook.row(row_index)[headers['*Permission Level']].downcase
        manager_name                = workbook.row(row_index)[headers['Manager']] || ''
        new_user['manager_id']      = User.find_by(first_name: manager_name).try(:id) unless new_user['roles'].include?("manager")
        new_user['manager_ids']     = [new_user['manager_id']]

        user = User.new(new_user)
        user.save(validate:false)
      end
    end

    def families
      (workbook_second_row..workbook.last_row).each do |row_index|
        new_family                = {}
        new_family['name']        = workbook.row(row_index)[headers['*Name']]
        new_family['code']        = workbook.row(row_index)[headers['*Family ID']]
        new_family['family_type'] = workbook.row(row_index)[headers['*Family Type']]
        new_family['status']      = workbook.row(row_index)[headers['*Family Status']]
        province_name             = workbook.row(row_index)[headers['Province']]
        new_family['province_id'] = find_province(province_name)
        district_name             = workbook.row(row_index)[headers['District']]
        new_family['district_id'] = find_district(district_name)
        commune_name              = workbook.row(row_index)[headers['Commune / Sangkat']]
        new_family['commune_id']  = find_commune(commune_name)
        village_name              = workbook.row(row_index)[headers['Village']] || ''
        new_family['village_id']  = find_village(village_name)
        family = Family.new(new_family)
        family.save(validate:false)
      end
    end

    def donors
      (workbook_second_row..workbook.last_row).each do |row_index|
        new_donor                 = {}
        new_donor['name']        = workbook.row(row_index)[headers['*Name']]
        new_donor['description'] = workbook.row(row_index)[headers['Description']]

        donor = Donor.new(new_donor)
        donor.save(validate:false)
      end
    end

    def clients
      (workbook_second_row..workbook.last_row).each do |row_index|
        new_client                        = {}
        new_client['given_name']          = workbook.row(row_index)[headers['Given Name (English)']]
        new_client['family_name']         = workbook.row(row_index)[headers['Family Name (English)']]
        family_id                         = workbook.row(row_index)[headers['Family ID']]
        new_client['current_family_id']   = Family.find_by(code: family_id).try(:id)
        donor_name                        = workbook.row(row_index)[headers['Donor ID']]
        new_client['donor_id']            = Donor.find_by(name: donor_name).try(:id)
        case_worker_name                  = workbook.row(row_index)[headers['*Case Worker ID']]
        new_client['user_id']             = User.find_by(first_name: case_worker_name).try(:id)
        new_client['user_ids']            = [new_client['user_id']]

        client = Client.new(new_client)
        client.save(validate:false)
        family_name   = workbook.row(row_index)[headers['Family ID']]
        family        = find_family(family_name)

        if family.present?
          family.children << client.id
          family.save
        end
        client.save
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

    def find_district(name)
      province = District.find_by(name: name)
      province.try(:id)
    end

    def find_commune(name)
      commune = Commune.find_by(name_en: name)
      commune.try(:id)
    end

    def find_village(name)
      village = Village.find_by(name_en: name)
      village.try(:id)
    end

    def find_family(family_id)
      Family.find_by(code: family_id)
    end
  end
end
