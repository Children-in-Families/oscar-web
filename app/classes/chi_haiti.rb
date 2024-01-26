module ChiHaiti
  class Import
    attr_accessor :path, :headers, :workbook, :workbook_second_row

    def initialize(path = '', sheets = [])
      @path = path
      @workbook = Roo::Excelx.new(path)
      @headers = {}
      @sheets = sheets
      @workbook_second_row = 2
    end

    def import_all
      sheets = ['families', 'users', 'clients']
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
        new_user['first_name'] = workbook.row(row_index)[headers['First Name']]&.squish
        new_user['last_name'] = workbook.row(row_index)[headers['Last Name']]&.squish
        new_user['email'] = workbook.row(row_index)[headers['*Email']]&.squish
        new_user['password'] = user_password
        new_user['gender'] = workbook.row(row_index)[headers['*Gender']]&.squish
        new_user['roles'] = workbook.row(row_index)[headers['*Permission Level']].downcase
        manager_name = workbook.row(row_index)[headers['Manager']] || ''
        new_user['manager_id'] = User.find_by(first_name: manager_name).try(:id) unless new_user['roles'].include?('manager')
        new_user['manager_ids'] = [new_user['manager_id']]

        user = find_or_initialize_by(new_user)
        user.save(validate: false)
      end
    end

    def find_or_initialize_by(attributes, &block)
      User.find_by(attributes.slice('first_name', 'last_name')) || User.new(attributes, &block)
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
        new_client['gender'] = workbook.row(row_index)[headers['* Gender']]&.downcase
        donor_name = workbook.row(row_index)[headers['Donor ID']]
        new_client['donor_id'] = Donor.find_by(name: donor_name).try(:id)

        new_client['date_of_birth'] = workbook.row(row_index)[headers['Date of Birth']].to_s
        begin
          new_client['initial_referral_date'] = headers['* Date of Referral'].present? && workbook.row(row_index)[headers['* Date of Referral']] && workbook.row(row_index)[headers['* Date of Referral']].to_s&.presence.to_date.strftime('%Y-%m-%d') || Time.now.to_s
        rescue Exception => e
          binding.pry
        end
        referral_source_category_name = headers['*Referral Source Category'] && workbook.row(row_index)[headers['*Referral Source Category']] || 'Non-Government Organization'
        referral_source_name = headers['Referral Source'] && workbook.row(row_index)[headers['Referral Source']] || 'Church'
        new_client['referral_source_category_id'] = ReferralSource.find_by(name_en: referral_source_category_name)&.id
        new_client['referral_source_id'] = find_or_create_referral_source(referral_source_name, new_client['referral_source_category_id'])

        referee_name = headers['* Name of Referee'] && workbook.row(row_index)[headers['* Name of Referee']] || 'Anonymous'
        referee_phone = headers['Referee Phone Number'] && workbook.row(row_index)[headers['Referee Phone Number']] || '123456789'
        new_client['referee_id'] = create_referee(name: referee_name, phone: referee_phone)

        new_client['rated_for_id_poor'] = workbook.row(row_index)[headers['Is the Client Rated for ID Poor?']] || ''
        new_client['has_been_in_orphanage'] = workbook.row(row_index)[headers['Has the client lived in an orphanage?']]&.squish&.downcase == 'yes' ? true : false
        new_client['has_been_in_government_care'] = workbook.row(row_index)[headers['Has the client lived in government care?']]&.squish&.downcase == 'yes' ? true : false
        new_client['relevant_referral_information'] = workbook.row(row_index)[headers['Relevant Referral Information / Notes']] || ''
        new_client['name_of_referee'] = workbook.row(row_index)[headers['* Name of Referee']]
        received_by_name = workbook.row(row_index)[headers['* Receiving Staff Member']] || 'Cindy'
        received_by_attr = { first_name: received_by_name.squish }
        new_client['received_by_id'] = create_user_received_by(received_by_attr)
        followed_up_by_name = workbook.row(row_index)[headers['First Follow-Up By']]
        new_client['followed_up_by_id'] = User.find_by(first_name: followed_up_by_name).try(:id)
        new_client['follow_up_date'] = workbook.row(row_index)[headers['First Follow-Up Date']]
        new_client['school_name'] = workbook.row(row_index)[headers['School Name']]
        new_client['main_school_contact'] = workbook.row(row_index)[headers['Main School Contact']]
        grade = workbook.row(row_index)[headers['School Grade']]
        new_client['school_grade'] = [Client::GRADES, I18n.t('advanced_search.fields.school_grade_list').values].transpose.to_h[grade]

        province_name = workbook.row(row_index)[headers['Address - Current Province']]
        district_name = workbook.row(row_index)[headers['Address - District']]
        commune_name = workbook.row(row_index)[headers['Address - Municipality']]
        locality = workbook.row(row_index)[headers['Address - Locality']]

        if province_name
          province = find_province(province_name.squish)
          new_client['province_id'] = province&.id
          pry_if_blank?(new_client['province_id'], province_name)
          district = find_district(province, district_name.squish)
          new_client['district_id'] = district&.id
          pry_if_blank?(new_client['district_id'], district_name)
          binding.pry if district.nil?
          commune = find_commune(district, commune_name.squish, new_client)
          new_client['commune_id'] = commune&.id
          pry_if_blank?(new_client['commune_id'], commune_name)
          new_client['locality'] = locality
        end

        birth_province_name = workbook.row(row_index)[headers['Client Birth Province']]
        if birth_province_name
          new_client['birth_province_id'] = find_province(birth_province_name.squish)&.id
          pry_if_blank?(new_client['birth_province_id'], birth_province_name)
        end
        new_client['house_number'] = workbook.row(row_index)[headers['Address - House Number']]
        new_client['street_number'] = workbook.row(row_index)[headers['Address - Street']]
        new_client['code'] = workbook.row(row_index)[headers['Custom ID Number 1']]
        new_client['kid_id'] = workbook.row(row_index)[headers['Custom ID Number 2']]
        case_worker_name = workbook.row(row_index)[headers['* Case Worker / Staff']]
        new_client['user_id'] = User.find_by(first_name: case_worker_name.split(' ').first).try(:id) if case_worker_name
        new_client['user_ids'] = [new_client['user_id']]

        carer_name = workbook.row(row_index)[headers['Primary Carer Name']]
        carer_name = (carer_name && carer_name[/(\w+\:\s?(\w+\s)+)|((\w+\s?)+(\(\w+\))?)/]).presence || carer_name
        carer_phone = workbook.row(row_index)[headers['Primary Carer Phone Number']]
        new_client['carer_id'] = create_carer(name: carer_name, phone: carer_phone) if carer_name

        begin
          client = Client.find_by(new_client.slice('given_name', 'family_name')) || Client.new(new_client)
          client.save!
        rescue Exception => e
          binding.pry
        end

        family_name = workbook.row(row_index)[headers['Family ID']]
        family = find_family(family_name)

        if family.present?
          family.children << client.id
          family.save
        end
        new_client['country_origin'] = 'haiti'
        client.case_worker_clients.find_or_create_by(user_id: new_client['user_id']) if new_client['user_id'].present?
      end
    end

    private

    def create_referee(attributes)
      if attributes[:name] && attributes[:name].downcase != 'unknown'
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
      user = User.find_or_create_by(first_name: attribute['first_name']) do |user|
        user.password = Devise.friendly_token.first(8)
        user.last_name = attribute['last_name'] || attribute['first_name']
        user.gender = attribute['gender'] || 'other'
        user.email = "#{attribute['first_name']}@childhope.org"
        user.roles = 'case worker'
        user.save
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
        puts 'Error: districts' if name && name.downcase != 'n/a'
      end
      district
    end

    def find_commune(district, name, new_client = {})
      communes = district && district.communes.where(name_en: name)
      commune = nil
      if communes && communes.count == 1
        commune = communes.first
      else
        puts 'Error: communes' if name && name.downcase != 'n/a'
      end
      commune
    end

    def find_village(commune, name)
      villages = communes && commune.villages.where(name_en: name)
      village = nil
      if villages && villages.count == 1
        village = villages.first
      else
        puts 'Error: villages' if name && name.downcase != 'n/a'
      end
      village
    end

    def find_family(family_id)
      Family.find_by(code: family_id)
    end

    def pry_if_blank?(address, name = '')
      puts "Error: address #{address}, name: #{name}" if (name.present? && name.downcase != 'n/a') && address.blank?
    end
  end
end
