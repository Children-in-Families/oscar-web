module ClientsImporter
  class Import
    attr_accessor :path, :headers, :workbook, :workbook_second_row

    def initialize(path='', sheets=[])
      @path       = path
      @workbook   = Roo::Excelx.new(path)
      @headers    = {}
      @sheets     = sheets
      @workbook_second_row = 2
    end

    def import_all
      sheets = @sheets.presence || ['users', 'families', 'donors', 'clients']
      sheets.each do |sheet_name|
        sheet_index = workbook.sheets.index(sheet_name)
        workbook.default_sheet = workbook.sheets[sheet_index]
        workbook.row(1).each_with_index { |header, i| headers[header] = i }
        self.send(sheet_name.to_sym)
      end
    end

    def users
      user_password = Devise.friendly_token.first(8)
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

        user = find_or_initialize_by(new_user)
        user.save(validate:false)
      end
    end

    def find_or_initialize_by(attributes, &block)
      User.find_by(attributes.slice('first_name', 'last_name')) || User.new(attributes, &block)
    end

    def families
      (workbook_second_row..workbook.last_row).each do |row_index|
        new_family                = {}
        new_family['name']        = workbook.row(row_index)[headers['*Name']]
        new_family['code']        = workbook.row(row_index)[headers['*Family ID']]
        new_family['family_type'] = workbook.row(row_index)[headers['*Family Type']]
        new_family['status']      = workbook.row(row_index)[headers['*Family Status']]
        province_name             = workbook.row(row_index)[headers['Province']]
        province                  = find_province(province_name)
        new_family['province_id'] = province&.id
        district_name             = workbook.row(row_index)[headers['District']]
        district                  = find_district(province.districts, district_name)
        new_family['district_id'] = district&.id
        commune_name              = workbook.row(row_index)[headers['Commune / Sangkat']]
        commune                   = find_commune(district.communes, commune_name)
        new_family['commune_id']  = commune&.id
        village_name              = workbook.row(row_index)[headers['Village']] || ''
        new_family['village_id']  = find_village(commuen.villages, village_name)&.id
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
      referral_source_hash = { "NGO" => "2", "Government" => "3" }
      received_by_id = create_user_received_by
      (workbook_second_row..workbook.last_row).each do |row_index|
        new_client                        = {}
        new_client['given_name']          = workbook.row(row_index)[headers['Given Name (English)']]
        new_client['family_name']         = workbook.row(row_index)[headers['Family Name (English)']]
        new_client['local_given_name']    = workbook.row(row_index)[headers['Given Name (Khmer)']]
        new_client['local_family_name']   = workbook.row(row_index)[headers['Family Name (Khmer)']]
        new_client['gender']              = workbook.row(row_index)[headers['* Gender']]&.downcase
        family_id                         = workbook.row(row_index)[headers['Family ID']]
        new_client['current_family_id']   = Family.find_by(code: family_id).try(:id)
        donor_name                        = workbook.row(row_index)[headers['Donor ID']]
        new_client['donor_id']            = Donor.find_by(name: donor_name).try(:id)

        new_client['date_of_birth']       = workbook.row(row_index)[headers['Date of Birth']].to_s
        new_client['initial_referral_date'] = workbook.row(row_index)[headers['* Initial Referral Date']].to_s

        referral_source_category_anme     = workbook.row(row_index)[headers['*Referral Category']]
        referral_source_name              = workbook.row(row_index)[headers['* Referral Source']]
        new_client['referral_source_category_id'] = ReferralSource.find_by(name_en: referral_source_category_anme)&.id
        new_client['referral_source_id']  = find_or_create_referral_source(referral_source_category_anme, new_client['referral_source_category_id'])
        new_client['referee_id']          = create_referee(workbook.row(row_index)[headers['* Name of Referee']])

        new_client['name_of_referee']     = workbook.row(row_index)[headers['* Name of Referee']]
        received_by_name                  = workbook.row(row_index)[headers['* Referral Received By']]
        new_client['received_by_id']      = received_by_id
        new_client['initial_referral_date'] = workbook.row(row_index)[headers['* Initial Referral Date']]
        followed_up_by_name               = workbook.row(row_index)[headers['First Follow-Up By']]
        new_client['followed_up_by_id']   = User.find_by(first_name: followed_up_by_name).try(:id)
        new_client['follow_up_date']      = workbook.row(row_index)[headers['First Follow-Up Date']]
        grade                             = workbook.row(row_index)[headers['School Grade']]
        new_client['school_grade']        = [Client::GRADES, I18n.t('advanced_search.fields.school_grade_list').values].transpose.to_h[grade]

        province_name                     = workbook.row(row_index)[headers['Current Province']]
        district_name                     = workbook.row(row_index)[headers['Address - District/Khan']]
        commune_name                      = workbook.row(row_index)[headers['Address - Commune/Sangkat']]
        village_name                      = workbook.row(row_index)[headers['Address - Village']]

        if province_name && province_name != 'An Yang'
          province = find_province(province_name.squish)
          new_client['province_id'] = province&.id
          pry_if_blank?(new_client['province_id'], province_name)
          district = find_district(province, district_name.squish)
          new_client['district_id'] = district&.id
          pry_if_blank?(new_client['district_id'], district_name)
          commune  = find_commune(district, commune_name.squish, new_client)
          new_client['commune_id'] = commune&.id
          pry_if_blank?(new_client['commune_id'], commune_name)
          village  = find_village(commune, village_name.squish) if commune
          new_client['village_id'] = village&.id
          pry_if_blank?(new_client['village_id'], village_name)
        end

        if province_name == 'An Yang'
          new_client['outside'] = true
          new_client['outside_address'] = "#{province_name}, #{district_name}, #{commune_name}, #{village_name}"
        end

        birth_province_name               = workbook.row(row_index)[headers['Client Birth Province']]
        if birth_province_name && (birth_province_name != 'Vinh Long' || birth_province_name != 'An Yang')
          new_client['birth_province_id']   = find_province(birth_province_name.squish)&.id
          pry_if_blank?(new_client['birth_province_id'], birth_province_name)
        end
        new_client['house_number']        = workbook.row(row_index)[headers['Address - House#']]
        new_client['street_number']       = workbook.row(row_index)[headers['Address - Street']]
        new_client['code']                = workbook.row(row_index)[headers['Custom ID Number 1']]
        case_worker_name                  = workbook.row(row_index)[headers['* Case Worker / Staff']]
        new_client['user_id']             = User.find_by(first_name: case_worker_name.split(' ').last.squish).try(:id)
        new_client['user_ids']            = [new_client['user_id']]

        client = Client.new(new_client)
        # client.save(validate:false)
        family_name   = workbook.row(row_index)[headers['Family ID']]
        family        = find_family(family_name)

        if family.present?
          family.children << client.id
          family.save
        end

        next if Client.find_by(new_client.slice('given_name', 'family_name')).present?
        client.save!
        client.case_worker_clients.find_or_create_by(user_id: new_client['user_id']) if new_client['user_id'].present?
      end
    end

    private

    def create_referee(name)
      if name && name.downcase != 'unknown'
        referee = Referee.find_or_create_by(name: name)
      else
        referee = Referee.create(name: 'Anonymous', anonymous: true)
      end
      referee&.id
    end

    def create_user_received_by
      user = User.find_or_create_by(first_name: 'CMS') do |user|
                user.password = Devise.friendly_token.first(8)
                user.last_name = 'CMS'
                user.gender = 'other'
                user.email = 'cms@ratanak.org'
                user.roles = 'case worker'
              end

      user&.id
    end

    def find_or_create_referral_source(name, parent_id)
      referral_source = ReferralSource.find_or_create_by(name: name, name_en: name, ancestry: parent_id)
      referral_source.try(:id)
    end

    def find_province(name)
      province = Province.where("name ILIKE ?", "%#{name}").first
    end

    def find_district(province, name)
      districts = province.districts.where("name ILIKE ?", "%#{name}")
      district = nil
      if districts.count == 1
        district = districts.first
      else
        puts "Error: districts" if name.downcase != 'n/a'
      end
      district
    end

    def find_commune(district, name, new_client={})
      communes = district.communes.where(name_en: name)
      commune = nil
      if communes.count == 1
        commune = communes.first
      else
        puts "Error: communes" if name.downcase != 'n/a'
      end
      commune
    end

    def find_village(commune, name)
      villages = commune.villages.where(name_en: name)
      village = nil
      if villages.count == 1
        village = villages.first
      else
        puts "Error: villages" if name.downcase != 'n/a'
      end
      village
    end

    def find_family(family_id)
      Family.find_by(code: family_id)
    end

    def pry_if_blank?(address, name='')
      return if name == 'Vinh Long' || name == 'An Yang'
      puts "Error: address #{address}, name: #{name}" if (name.present? && name.downcase != 'n/a') && address.blank?
    end
  end
end
