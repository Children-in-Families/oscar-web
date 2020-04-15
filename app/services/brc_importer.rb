class BrcImporter
  attr_accessor :path, :headers, :workbook, :workbook_second_row

  def initialize
    @path       = 'db/support/brc_client.xlsx'
    @workbook   = Roo::Excelx.new(path)
    @headers    = {}
    @workbook_second_row = 2
  end

  def import_all
    create_custom_referral_data

    sheets = %w(family user client)
    # Skip importing user in staging
    sheets = %w(family client)
    sheets.each do |sheet_name|
      sheet_index = workbook.sheets.index(sheet_name)
      workbook.default_sheet = workbook.sheets[sheet_index]
      workbook.row(1).each_with_index { |header, i| headers[header] = i }
      public_send("import_#{sheet_name}".to_sym)
    end
  end

  def create_custom_referral_data
    QuantitativeType.destroy_all

    quantitative_type = QuantitativeType.create!(name: 'Change in Livelihood')
    quantitative_type.quantitative_cases.create!(value: 'Yes')
    quantitative_type.quantitative_cases.create!(value: 'No')

    quantitative_type = QuantitativeType.create!(name: 'Home Situation')
    quantitative_type.quantitative_cases.create!(value: 'Experienced a change in family situation')
    quantitative_type.quantitative_cases.create!(value: 'Anticipate being able to return and live into your residence within the next 30 days')

    quantitative_type = QuantitativeType.create!(name: 'Disabilities')
    quantitative_type.quantitative_cases.create!(value: 'Difficulty seeing, even if wearing glasses')
    quantitative_type.quantitative_cases.create!(value: 'Difficulty hearing, even using hearing aid')
    quantitative_type.quantitative_cases.create!(value: 'Difficulty walking or climbing steps')
    quantitative_type.quantitative_cases.create!(value: 'Difficulty remebering or concentrating')
    quantitative_type.quantitative_cases.create!(value: 'Difficulty with (self-care such as) washing or dresing')
    quantitative_type.quantitative_cases.create!(value: 'Using your usual language, do you have dificulty communicating, for example understanding or being understood')
    quantitative_type.quantitative_cases.create!(value: 'Yes - Needs follow up')
    quantitative_type.quantitative_cases.create!(value: 'No')

    quantitative_type = QuantitativeType.create!(name: 'Interview location')
    quantitative_type.quantitative_cases.create!(value: 'New Providence')
    quantitative_type.quantitative_cases.create!(value: 'Grand Bahama')
    quantitative_type.quantitative_cases.create!(value: 'Acklins')
    quantitative_type.quantitative_cases.create!(value: 'Andros')
    quantitative_type.quantitative_cases.create!(value: 'Berry Islands')
    quantitative_type.quantitative_cases.create!(value: 'Bimini')
    quantitative_type.quantitative_cases.create!(value: 'Cat Island')
    quantitative_type.quantitative_cases.create!(value: 'Crooked Island')
    quantitative_type.quantitative_cases.create!(value: 'Eleuthera')
    quantitative_type.quantitative_cases.create!(value: 'Exuma and Cays')
    quantitative_type.quantitative_cases.create!(value: 'Harbour Island')
    quantitative_type.quantitative_cases.create!(value: 'Inagua')
    quantitative_type.quantitative_cases.create!(value: 'Long Island')
    quantitative_type.quantitative_cases.create!(value: 'Mayaguana')
    quantitative_type.quantitative_cases.create!(value: 'Ragged Island')
    quantitative_type.quantitative_cases.create!(value: 'Rum Cay')
    quantitative_type.quantitative_cases.create!(value: 'San Salvador')
    quantitative_type.quantitative_cases.create!(value: 'Spanish Wells')
    quantitative_type.quantitative_cases.create!(value: 'Abaco Islands')

    quantitative_type = QuantitativeType.create!(name: 'Consent')
    quantitative_type.quantitative_cases.create!(value: 'Consent to collect, store and analyze information')
    quantitative_type.quantitative_cases.create!(value: 'Contact via 3rd party messages')
  end

  def import_user
    (workbook_second_row..workbook.last_row).each do |row_index|
      new_user = {}
      new_user['gender']          = workbook.row(row_index)[headers['*Gender']].downcase
      new_user['first_name']      = workbook.row(row_index)[headers['First Name']]
      new_user['last_name']       = workbook.row(row_index)[headers['Last Name']]
      new_user['email']           = workbook.row(row_index)[headers['*Email']]
      new_user['password']        = Devise.friendly_token.first(8)
      new_user['roles']           = workbook.row(row_index)[headers['*Permission Level']].downcase
      manager_name                = workbook.row(row_index)[headers['Manager']] || ''
      new_user['manager_id']      = User.find_by(first_name: manager_name).try(:id) unless new_user['roles'].include?("manager")
      new_user['manager_ids']     = [new_user['manager_id']]

      user = find_or_initialize_by(new_user)
      user.save(validate:false)
    end
  end

  def import_family
    (workbook_second_row..workbook.last_row).each do |row_index|
      new_family                = {}
      new_family['name']        = workbook.row(row_index)[headers['*Name']]
      new_family['code']        = workbook.row(row_index)[headers['*Family ID']]
      new_family['family_type'] = workbook.row(row_index)[headers['*Family Type']]
      new_family['status']      = workbook.row(row_index)[headers['*Family Status']]

      # Make random data
      new_family['name'] = "#{FFaker::Name.first_name} #{FFaker::Name.last_name}"

      family = Family.find_by(code: new_family['code'])

      if family.blank?
        family = Family.new(new_family)
        family.save(validate: false)
      end

      member = family.family_members.find_by(adult_name: workbook.row(row_index)[headers['*Name']])

      if member.blank?
        family.family_members << FamilyMember.create!(
          adult_name: new_family['name'],
          gender: workbook.row(row_index)[headers['Sex']].downcase,
          date_of_birth: workbook.row(row_index)[headers['Date of birth']]
        )
      end
    end
  end

  def import_client
    find_or_create_case_worker

    (workbook_second_row..workbook.last_row).each do |row_index|
      new_client                        = {}
      family_id                         = workbook.row(row_index)[headers['*Family ID']]

      new_client['user_ids']              = [@case_worker.id]
      new_client['initial_referral_date'] = workbook.row(row_index)[headers['Initial Referral Date']].to_s
      new_client['given_name']          = workbook.row(row_index)[headers['First Name']]
      new_client['family_name']         = workbook.row(row_index)[headers['Last Name']]
      new_client['presented_id']        = workbook.row(row_index)[headers['Presented ID']]
      new_client['id_number']           = workbook.row(row_index)[headers['ID number']]
      new_client['client_phone']        = workbook.row(row_index)[headers['Phone Number - Primary']]
      new_client['whatsapp']            = workbook.row(row_index)[headers['Whatsapp?']]
      new_client['other_phone_number']  = workbook.row(row_index)[headers['Phone Number - Alternate']]
      new_client['other_phone_whatsapp']  = workbook.row(row_index)[headers['other phone - Whatsapp?']]
      new_client['local_given_name']    = workbook.row(row_index)[headers['First Name - Alternate']]
      new_client['local_family_name']   = workbook.row(row_index)[headers['Last Name - Alternate']]
      new_client['gender']              = workbook.row(row_index)[headers['Gender']]&.downcase
      new_client['date_of_birth']       = workbook.row(row_index)[headers['Date of Birth']].to_s
      new_client['brsc_branch']         = workbook.row(row_index)[headers['BRCS Branch']]
      new_client['preferred_language']  = workbook.row(row_index)[headers['Preferred Language']] || 'English'
      new_client['current_island']      = workbook.row(row_index)[headers['Island - Current address']]
      new_client['current_street']      = workbook.row(row_index)[headers['Street - Current address']]
      new_client['current_po_box']      = workbook.row(row_index)[headers['Zip Code/PO BOX - Current address']]
      new_client['current_settlement']  = workbook.row(row_index)[headers['City/Settlement - Current address']]
      new_client['current_resident_own_or_rent']  = workbook.row(row_index)[headers['Is your household staying in one of the following?']]

      new_client['island2']             = workbook.row(row_index)[headers['Island - Other address']]
      new_client['settlement2']         = workbook.row(row_index)[headers['City - Other address']]
      new_client['street2']             = workbook.row(row_index)[headers['Street - Other address']]
      new_client['po_box2']             = workbook.row(row_index)[headers['Zip - Other address']]
      new_client['resident_own_or_rent2'] = workbook.row(row_index)[headers['Owned, Rented or Temporary - Other address']]
      new_client['household_type2'] = workbook.row(row_index)[headers['Address Type - Other address']]
      new_client['relevant_referral_information'] = workbook.row(row_index)[headers['Additional Information']]
      new_client['legacy_brcs_id'] = workbook.row(row_index)[headers['Legacy BRCS-ID number']]

      new_client.each do |k, v|
        new_client[k] = nil if v == '0' || v == 0
        # Make data random
        sensitive_fields = %w(id_number legacy_brcs_id)

        if k.in?(sensitive_fields) && v.present?
          v = v.to_s + '123'
          new_client[k] = v.split('').map{ |c| v.split('').sample }.join
        end
      end

      # Make data random
      new_client['given_name'] = FFaker::Name.first_name
      new_client['family_name'] = FFaker::Name.last_name
      new_client['local_given_name'] = FFaker::Name.first_name
      new_client['local_family_name'] = FFaker::Name.last_name

      new_client['current_street'] = FFaker::Address.street_address
      new_client['street2'] = FFaker::Address.street_address

      new_client['client_phone'] = FFaker::PhoneNumber.phone_number
      new_client['other_phone_number'] = FFaker::PhoneNumber.phone_number

      family = Family.find_by(code: family_id)

      new_client['current_family_id']   = family.try(:id)
      new_client['received_by_id']      = @case_worker.id
      new_client['referral_source_category_id'] = ReferralSource.find_by(name_en: 'Family')&.id

      client = Client.new(new_client)

      begin
        client.save!
      rescue => e
        pp e
        pp new_client
        return
      end

      if family.present?
        family.update_columns(caregiver_information: workbook.row(row_index)[headers['Relevant Referral Information / Notes']])
      end

      {
        'Change in Livelihood' => 'Change in Livelihood',
        'Home Situation' => 'Home Situation',
        'Disabilities' => '11 1 Disabilities',
        'Interview location' => '11 3 Interview location',
        'Consent' => 'Consent'
      }.each do |name, header_name|
        value = workbook.row(row_index)[headers[header_name]]

        if value.present? && !value.in?(['0', 0])
          value = value.titleize if name == 'Change in Livelihood'

          value.split("|").each do |v|
            begin
              v = v.strip
              quantitative_type = QuantitativeType.find_by!(name: name)
              quantitative_case = quantitative_type.quantitative_cases.find_by!(value: v)
              client.client_quantitative_cases.create!(quantitative_case: quantitative_case)
            rescue
              pp '-------------'
              pp "---#{v.strip}----"
              pp name
              pp header_name
            end
          end
        end
      end
    end
  end

  private

  def find_or_initialize_by(attributes, &block)
    User.find_by(attributes.slice('first_name', 'last_name')) || User.new(attributes, &block)
  end

  def find_or_create_case_worker
    @case_worker ||= User.find_or_create_by(
      gender: :male,
      email: 'unassigned.case@ifrc.com',
      roles: 'case worker'
    )

    if @case_worker.new_record?
      @case_worker.first_name = 'Unassigned'
      @case_worker.last_name = 'Case'
      @case_worker.password = Devise.friendly_token.first(8)
      @case_worker.save(validate:false)
    end
  end
end
