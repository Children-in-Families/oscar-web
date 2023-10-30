module ClientsImporter
  class Import
    attr_accessor :path, :headers, :workbook, :workbook_second_row, :domain

    def initialize(path = '', sheets = [], domain = 'domain')
      @path = path
      @workbook = Roo::Excelx.new(path)
      @headers = {}
      @sheets = sheets
      @workbook_second_row = 2
      @domain = domain
    end

    def import_all
      sheets = @sheets.presence || { users: 'users', families: 'families', donors: 'donors', clients: 'clients' }
      sheets.each do |sheet, sheet_name|
        sheet_index = workbook.sheets.index(sheet_name)
        workbook.default_sheet = workbook.sheets[sheet_index]
        workbook.row(1).each_with_index { |header, i| headers[header] = i }
        self.send(sheet)
      end
    end

    def users
      user_password = Devise.friendly_token.first(8)
      (workbook_second_row..workbook.last_row).each do |row_index|
        new_user = {}
        new_user['first_name'] = workbook.row(row_index)[headers['First Name']]
        new_user['last_name'] = workbook.row(row_index)[headers['Last Name']]
        new_user['email'] = workbook.row(row_index)[headers['*Email']]&.downcase
        new_user['password'] = user_password
        new_user['gender'] = workbook.row(row_index)[headers['*Gender']]
        new_user['roles'] = workbook.row(row_index)[headers['*Permission Level']].downcase
        manager_name = workbook.row(row_index)[headers['Manager']] || ''
        new_user['manager_id'] = User.find_by(first_name: manager_name).try(:id) unless new_user['roles'].include?('manager')
        new_user['manager_ids'] = [new_user['manager_id']]

        user = find_or_initialize_by(new_user)
        user.save unless user.persisted?
      end
      puts '==============================Done import users======================================='
    end

    def find_or_initialize_by(attributes, &block)
      user = User.find_by(email: attributes['email'])
      if user
        attributes.delete('email')
        user.update_attributes(attributes)
        user
      else
        User.new(attributes, &block)
      end
    end

    def families
      (workbook_second_row..workbook.last_row).each do |row_index|
        new_family = {}
        new_family['name'] = workbook.row(row_index)[headers['*Name']]
        new_family['code'] = workbook.row(row_index)[headers['*Family ID']]
        new_family['family_type'] = workbook.row(row_index)[headers['*Family Type']]
        new_family['status'] = workbook.row(row_index)[headers['*Family Status']]
        province_name = workbook.row(row_index)[headers['Province / City']]&.squish
        province = find_province(province_name)
        new_family['province_id'] = province&.id
        pry_if_blank?(new_family['province_id'], province_name)
        district_name = workbook.row(row_index)[headers['District / Khan']]&.squish
        district = find_district(province, district_name)
        new_family['district_id'] = district&.id
        pry_if_blank?(new_family['district_id'], district_name)
        commune_name = workbook.row(row_index)[headers['Commune / Sangkat']]&.squish
        commune = find_commune(district, commune_name)
        new_family['commune_id'] = commune&.id
        village_name = workbook.row(row_index)[headers['Village']]&.squish || ''
        new_family['village_id'] = find_village(commune, village_name)&.id if commune

        new_family['house'] = workbook.row(row_index)[headers['House#']] || ''
        new_family['street'] = workbook.row(row_index)[headers['Street']] || ''

        family = find_family_or_initialize_by(new_family)
        family.save(validate: false)
      end
    end

    def find_family_or_initialize_by(attributes, &block)
      Family.find_by(attributes.slice('name')) || Family.new(attributes, &block)
    end

    def donors
      (workbook_second_row..workbook.last_row).each do |row_index|
        new_donor = {}
        new_donor['name'] = workbook.row(row_index)[headers['*Name']]
        new_donor['code'] = workbook.row(row_index)[headers['*Donor ID']]
        new_donor['description'] = workbook.row(row_index)[headers['Description']]

        donor = Donor.find_by(new_donor.slice('name')) || Donor.new(new_donor)
        donor.save(validate: false)
      end
    end

    def clients
      (workbook_second_row..workbook.last_row).each do |row_index|
        new_client = {}
        new_client['given_name'] = workbook.row(row_index)[headers['Given Name (English)']]
        new_client['family_name'] = workbook.row(row_index)[headers['Family Name (English)']]
        new_client['local_family_name'] = workbook.row(row_index)[headers['Family Name (Khmer)']]
        new_client['local_given_name'] = workbook.row(row_index)[headers['Given Name (Khmer)']]
        next if Client.find_by(new_client.slice('local_given_name', 'local_family_name')).present?

        new_client['gender'] = workbook.row(row_index)[headers['* Gender']]&.downcase
        family_id = workbook.row(row_index)[headers['Family ID']]
        new_client['current_family_id'] = Family.find_by(code: family_id).try(:id)
        donor_name = workbook.row(row_index)[headers['Donor ID']]
        new_client['donor_id'] = Donor.find_by(name: donor_name).try(:id)

        new_client['date_of_birth'] = workbook.row(row_index)[headers['Date of Birth']].to_s
        new_client['initial_referral_date'] = workbook.row(row_index)[headers['* Initial Referral Date']].to_s
        referral_source_category_name = workbook.row(row_index)[headers['* Referral Source Category']]
        referral_source_name = workbook.row(row_index)[headers['Referral Source']]
        new_client['referral_source_category_id'] = ReferralSource.find_or_create_by(name: referral_source_category_name, name_en: referral_source_category_name)&.id
        binding.pry if new_client['referral_source_category_id'].nil?
        new_client['referral_source_id'] = find_or_create_referral_source(referral_source_name, new_client['referral_source_category_id'])

        referee_name = workbook.row(row_index)[headers['* Name of Referee']]
        referee_phone = workbook.row(row_index)[headers['Referee Phone Number']]
        new_client['referee_id'] = create_referee(name: referee_name, phone: referee_phone)

        new_client['rated_for_id_poor'] = workbook.row(row_index)[headers['Is the Client Rated for ID Poor?']] || ''
        new_client['has_been_in_orphanage'] = workbook.row(row_index)[headers['Has the client lived in an orphanage?']]&.squish&.downcase == 'yes' ? true : false
        new_client['has_been_in_government_care'] = workbook.row(row_index)[headers['Has the client lived in government care?']]&.squish&.downcase == 'yes' ? true : false
        new_client['relevant_referral_information'] = workbook.row(row_index)[headers['Relevant Referral Information / Notes']] || ''
        received_by_name = workbook.row(row_index)[headers['* Referral Received By']]
        new_client['received_by_id'] = create_user_received_by(last_name: received_by_name.split(' ').last.squish)
        followed_up_by_name = workbook.row(row_index)[headers['First Follow-Up By']]
        new_client['followed_up_by_id'] = User.find_by(first_name: followed_up_by_name.split(' ').first).try(:id) if followed_up_by_name
        new_client['follow_up_date'] = workbook.row(row_index)[headers['First Follow-Up Date']]
        new_client['school_name'] = workbook.row(row_index)[headers['School Name']]
        new_client['main_school_contact'] = workbook.row(row_index)[headers['Main School Contact']]
        grade = workbook.row(row_index)[headers['School Grade']]
        new_client['school_grade'] = [Client::GRADES, I18n.t('advanced_search.fields.school_grade_list').values].transpose.to_h[grade]

        province_name = workbook.row(row_index)[headers['Current Province']]
        district_name = workbook.row(row_index)[headers['Address - District/Khan']]
        commune_name = workbook.row(row_index)[headers['Address - Commune/Sangkat']]
        village_name = workbook.row(row_index)[headers['Address - Village']]

        if province_name && province_name != 'An Yang'
          province = find_province(province_name&.squish)
          new_client['province_id'] = province&.id
          pry_if_blank?(new_client['province_id'], province_name)
          district = find_district(province, district_name&.squish) if district_name.squish.present?
          new_client['district_id'] = district&.id
          pry_if_blank?(new_client['district_id'], district_name)
          commune = find_commune(district, commune_name&.squish, new_client) if commune_name&.squish.present?
          new_client['commune_id'] = commune&.id
          pry_if_blank?(new_client['commune_id'], commune_name)
          village = find_village(commune, village_name&.squish) if commune
          new_client['village_id'] = village&.id
          pry_if_blank?(new_client['village_id'], village_name)
        end

        if province_name == 'An Yang'
          new_client['outside'] = true
          new_client['outside_address'] = "#{province_name}, #{district_name}, #{commune_name}, #{village_name}"
        end

        birth_province_name = workbook.row(row_index)[headers['Client Birth Province']]
        if birth_province_name && (birth_province_name != 'Vinh Long' || birth_province_name != 'An Yang')
          new_client['birth_province_id'] = find_province(birth_province_name.squish)&.id
          pry_if_blank?(new_client['birth_province_id'], birth_province_name)
        end
        new_client['house_number'] = workbook.row(row_index)[headers['Address - House#']]
        new_client['street_number'] = workbook.row(row_index)[headers['Address - Street']]
        new_client['code'] = workbook.row(row_index)[headers['Custom ID Number 1']]
        case_worker_id = workbook.row(row_index)[headers['*Case Worker ID']]
        case_worker_names = workbook.row(row_index)[headers['* Case Worker / Staff']]

        if case_worker_names.split(',').length > 1
          case_worker_ids = case_worker_names.split(',').map do |caseworker_name|
            create_user_received_by(last_name: caseworker_name.split(' ').last.squish)
          end
          new_client['user_ids'] = case_worker_ids
        else
          case_worker_name = case_worker_names.split(',').first.squish
          new_client['user_id'] = create_user_received_by(last_name: case_worker_name.split(' ').last.squish)
          new_client['user_ids'] = [new_client['user_id']]
        end

        carer_name = workbook.row(row_index)[headers['Primary Carer Name']]
        carer_phone = workbook.row(row_index)[headers['Primary Carer Phone Number']]
        new_client['carer_id'] = create_carer(name: carer_name, phone: carer_phone)

        Client.skip_callback(:commit, :after, :do_duplicate_checking)
        client = Client.find_by(new_client.slice('local_given_name', 'local_family_name')) || Client.new(new_client)
        client.save! unless client.persisted?

        family_name = workbook.row(row_index)[headers['Family ID']]
        family = find_family(family_name)

        if family.present?
          family.children << client.id
          family.save
        end

        client.case_worker_clients.find_or_create_by(user_id: new_client['user_id']) if new_client['user_id'].present?
      end
    end

    private

    def create_referee(attributes)
      if attributes[:name] && attributes[:name].downcase != 'unknown' || attributes[:name].downcase != 'anonymous'
        referee = Referee.find_or_create_by(name: attributes[:name]) do |ref|
          ref.phone = attributes[:phone]
        end
      else
        referee = Referee.create(name: 'Anonymous', anonymous: true)
      end
      referee&.id
    end

    def create_user_received_by(attributes)
      attribute = attributes.with_indifferent_access
      user = User.find_or_create_by(last_name: attribute['last_name']) do |object|
        object.password = Devise.friendly_token.first(8)
        object.last_name = attribute['last_name']
        object.gender = attribute['gender'] || 'other'
        object.email = "#{attribute['last_name']}@#{domain}.org"
        object.roles = 'case worker'
      end

      user&.id
    end

    def create_carer(attributes)
      attribute = attributes.with_indifferent_access
      carer = Carer.find_or_create_by(name: attribute['name']) do |care|
        care.phone = attribute['phone']
      end
      carer&.id
    end

    def find_or_create_referral_source(name, parent_id)
      referral_source = ReferralSource.find_or_create_by(name: name, name_en: name, ancestry: parent_id)
      referral_source.try(:id)
    end

    def find_province(name)
      province = Province.where('name ILIKE ?', "%#{name}").first
    end

    def find_district(province, name)
      districts = province.districts.where('name ILIKE ?', "%#{name}")
      district = nil
      if districts.count == 1
        district = districts.first
      else
        puts "Error: districts name #{name}" if name.downcase != 'n/a'
        raise
      end
      district
    rescue
      binding.pry
    end

    def find_commune(district, name, new_client = {})
      communes = district.communes.where(name_en: name)
      commune = nil
      if communes.count == 1
        commune = communes.first
      else
        puts 'Error: communes' if name.downcase != 'n/a'
      end
      commune
    rescue
      binding.pry
    end

    def find_village(commune, name)
      return if name.nil?
      villages = commune.villages.where(name_en: name)
      village = nil
      if villages.count == 1
        village = villages.first
      else
        puts 'Error: villages' if name&.downcase != 'n/a'
        raise
      end
      village
    rescue
      binding.pry
    end

    def find_family(family_id)
      Family.find_by(code: family_id)
    end

    def pry_if_blank?(address, name = '')
      return if name == 'Vinh Long' || name == 'An Yang'
      puts "Error: address #{address}, name: #{name}" if (name.present? && name.downcase != 'n/a') && address.blank?
    end
  end
end
