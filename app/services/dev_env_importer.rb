module DevEnvImporter
  class Import
    attr_accessor :path, :headers, :workbook, :workbook_second_row

    def initialize(path='lib/devdata/dev_tenant.xlsx')
      @path       = path
      @workbook   = Roo::Excelx.new(path)
      @headers    = {}
      @workbook_second_row = 2
    end

    def import_all
      sheets = ['users', 'families', 'clients']

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
      (workbook_second_row..workbook.last_row).each do |row_index|
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

        family_name   = workbook.row(row_index)[headers['Family Name']]
        family        = find_family(family_name)

        if family.present?
          family.children << client.id
          family.save
        end
      end
    end

    def field_settings
      (workbook_second_row..workbook.last_row).each do |row_index|
        # In case sheet is messed up
        next if workbook.row(row_index)[headers['name']].blank?

        FieldSetting.create!(
          name: workbook.row(row_index)[headers['name']],
          label: workbook.row(row_index)[headers['label']],
          type: workbook.row(row_index)[headers['type']],
          current_label: workbook.row(row_index)[headers['current_label']],
          klass_name: workbook.row(row_index)[headers['klass_name']],
          required: workbook.row(row_index)[headers['required']],
          visible: workbook.row(row_index)[headers['visible']],
          for_instances: workbook.row(row_index)[headers['for_instances']],
          group: workbook.row(row_index)[headers['group']]
        )
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
  end
end
