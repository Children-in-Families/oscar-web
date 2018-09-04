module HoltImporter
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = 'vendor/data/holt.xlsx')
      @path     = path
      @workbook = Roo::Excelx.new(path)

      sheet_index = workbook.sheets.index(sheet_name)
      workbook.default_sheet = workbook.sheets[sheet_index]
      sheet_header
    end

    def sheet_header
      @headers = Hash.new
      workbook.row(1).each_with_index { |header, i|
        headers[header] = i
      }
    end

    def families
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        name               = workbook.row(row)[headers['*Name']]
        code               = workbook.row(row)[headers['*Family ID']]
        family_type        = workbook.row(row)[headers['Family Type']]
        case_history       = workbook.row(row)[headers['Family History']]
        status             = 'Active'
        Family.create(name: name, code: code, case_history: case_history, family_type: family_type, status: status)
      end
    end

    def clients
      ((workbook.first_row + 1)..workbook.last_row).each do |row|

        family_name           = workbook.row(row)[headers['Family Name (English)']] || ''
        given_name            = workbook.row(row)[headers['Given Name (English)']] || ''
        local_family_name     = workbook.row(row)[headers['Family Name (Khmer)']] || ''
        local_given_name      = workbook.row(row)[headers['Given Name (Khmer)']] || ''
        gender                = workbook.row(row)[headers['Gender']]
        dob                     = format_date_of_birth(workbook.row(row)[headers['Date of Birth']].to_s)
        referral_source_id      = find_referral_source(workbook.row(row)[headers['* Referral Source']]).id
        name_of_referee         = workbook.row(row)[headers['* Name of Referee']] || ''
        referral_phone          = workbook.row(row)[headers['Referee Phone Number']] || ''
        received_by_id          = User.find_by(first_name: workbook.row(row)[headers['* Referral Received By']]).id
        initial_referral_date   = format_date_of_birth(workbook.row(row)[headers['* Initial Referral Date']].to_s)
        follow_up_by_id         = User.find_by(first_name: workbook.row(row)[headers['First Follow-Up By']]).id
        follow_up_date          = format_date_of_birth(workbook.row(row)[headers['First Follow-Up Date']].to_s)
        user_id                 = User.find_by(first_name: workbook.row(row)[headers['* Case Worker / Staff']]).id
        live_with               = workbook.row(row)[headers['Primary Carer Name']] || ''
        telephone_number        = workbook.row(row)[headers['Primary Carer Phone Number']] || ''
        current_province        = Province.where("name ilike ?", "%Battambang%").first
        district                = current_province.districts.where("name ilike ?", "%Sangkae%").first if current_province.present?
        #commune                 = workbook.row(row)[headers['Address - Commune/Sangkat']] || ''
        # commune_name            = workbook.row(row)[headers['Address - Commune/Sangkat']] || ''
        # commune                 = district.communes.where("name ilike ?", "%#{commune_name}%").first if commune_name.present? && district.present?
        house                   = workbook.row(row)[headers['Address - House#']] || ''
        #village                 = workbook.row(row)[headers['Address - Village']] || ''
        # village_name            = workbook.row(row)[headers['Address - Village']] || ''
        # village                 = commune.villages.where("name ilike ?", "%#{village_name}%").first if village_name.present? && commune.present?
        school_name             = workbook.row(row)[headers['School Name']] || ''
        school_grade            = workbook.row(row)[headers['School Grade']] || ''
        main_school_contact     = workbook.row(row)[headers['Main School Contact']] || ''
        Organization.switch_to 'shared'
        birth_province          = Province.where("name ilike ?", "%Battambang%").first.try(:id)
        Organization.switch_to 'holt'
        rated_for_id_poor       = workbook.row(row)[headers['Is the Client Rated for ID Poor?']] || ''
        has_been_in_orphanage   = false
        has_been_in_government_care = false
        code                    = workbook.row(row)[headers['Custom ID Number 1']] || ''
        relevant_referral_information  = workbook.row(row)[headers['Relevant Referral Information / Notes']] || ''
        family_code             = workbook.row(row)[headers['Family ID']] || ''
        family                  = Family.find_by(code: family_code)
        agency_name             = workbook.row(row)[headers['Other Agencies Involved']]
        agency_id               = Agency.find_or_create_by(name: agency_name).id if agency_name.present?

        client = Client.new(
          family_name: family_name,
          given_name: given_name,
          local_given_name: local_given_name,
          local_family_name: local_family_name,
          gender: gender,
          date_of_birth: dob,
          referral_source_id: referral_source_id,
          name_of_referee: name_of_referee,
          referral_phone: referral_phone,
          received_by_id: received_by_id,
          initial_referral_date: initial_referral_date,
          followed_up_by_id: follow_up_by_id,
          follow_up_date: follow_up_date,
          live_with: live_with,
          telephone_number: telephone_number,
          province_id: current_province.try(:id),
          district_id: district.try(:id),
          #commune: commune,
          # commune_id: commune.try(:id),
          house_number: house,
          #village: village,
          # village_id: village.try(:id),
          school_name: school_name,
          school_grade: school_grade,
          main_school_contact: main_school_contact,
          birth_province_id: birth_province,
          rated_for_id_poor: rated_for_id_poor,
          has_been_in_orphanage: has_been_in_orphanage,
          has_been_in_government_care: has_been_in_government_care,
          code: code,
          relevant_referral_information: relevant_referral_information,
          user_ids: [user_id],
          country_origin: 'cambodia'
        )
        client.save(validate: false)

        AgencyClient.create(client_id: client.id, agency_id: agency_id) if agency_id.present?
        if family.present?
          family.children << client.id
          family.save(validate: false)
        end
      end
    end

    def format_date_of_birth(value)
      first_regex  = /\A\d{2}\/\d{2}\/\d{2}\z/
      second_regex = /\A\d{4}\z/
      ages = ['5', '6', '7', '8', '10', '37', '39']

      if value =~ first_regex
        value  = value.split('/')
        year = "20#{value.last}"
        value  = value.shift(2)
        value  = value.push(year)
        value  = value.join('-')
      elsif value =~ second_regex
        value = "01-01-#{value}"
      elsif ages.include?(value)
        value = value.to_i.years.ago.to_date
      end
      value
    end

    def find_referral_source(value)
      ReferralSource.find_or_create_by(name: value)
    end

    def users
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        first_name = workbook.row(row)[headers['First Name']]
        last_name  = workbook.row(row)[headers['Last Name']]
        email      = workbook.row(row)[headers['*Email']]
        roles      = workbook.row(row)[headers['*Permission Level']].downcase
        password   = (('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a).sample(8).join

        User.create(first_name: first_name, last_name: last_name, email: email, password: password, roles: roles)
      end
    end
  end
end
