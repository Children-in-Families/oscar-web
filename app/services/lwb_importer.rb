module LwbImporter
  class Import
    attr_accessor :path, :headers, :workbook, :workbook_second_row

    def initialize(path='lib/devdata/lwb.xlsx')
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
        new_user['gender']          = workbook.row(row_index)[headers['*Gender']]
        new_user['email']           = workbook.row(row_index)[headers['*Email']]
        new_user['password']        = user_password
        new_user['roles']           = workbook.row(row_index)[headers['*Permission Level']].downcase

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
        family = Family.new(new_family)
        family.save(validate:false)
      end
    end

    def donors
      (workbook_second_row..workbook.last_row).each do |row_index|
        new_donor                 = {}
        new_donor['name']        = workbook.row(row_index)[headers['*Name']]
        new_donor['code']        = workbook.row(row_index)[headers['*Donor ID']]

        donor = Donor.new(new_donor)
        donor.save(validate:false)
      end
    end

    def clients
      (workbook_second_row..workbook.last_row).each do |row_index|
        new_client                                  = {}
        new_client['given_name']                    = workbook.row(row_index)[headers['Given Name (English)']]
        new_client['family_name']                   = workbook.row(row_index)[headers['Family Name (English)']]
        new_client['gender']                        = workbook.row(row_index)[headers['* Gender']]
        referral_source_catgeory_name               = workbook.row(row_index)[headers['*Referral Category']]
        new_client['referral_source_category_id']   = ReferralSource.find_by(name_en: referral_source_catgeory_name).try(:id)
        referral_source_name                        = workbook.row(row_index)[headers['* Referral Source']]
        new_client['referral_source_id']            = ReferralSource.find_by(name_en: referral_source_name).try(:id)
        new_client['name_of_referee']               = workbook.row(row_index)[headers['* Name of Referee']]
        received_by_name                            = workbook.row(row_index)[headers['* Referral Received By']]
        new_client['received_by_id']                = User.find_by(first_name: received_by_name).try(:id)
        new_client['initial_referral_date']         = workbook.row(row_index)[headers['* Initial Referral Date']]
        family_id                                   = workbook.row(row_index)[headers['Family ID']]
        new_client['current_family_id']             = Family.find_by(code: family_id).try(:id)
        case_worker_name                            = workbook.row(row_index)[headers['*Case Worker ID']]
        new_client['user_id']                       = User.find_by(first_name: case_worker_name).try(:id)
        new_client['user_ids']                      = [new_client['user_id']]

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

    def find_family(family_id)
      Family.find_by(code: family_id)
    end
  end
end
