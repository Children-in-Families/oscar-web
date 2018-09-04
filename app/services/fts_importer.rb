module FtsImporter
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = 'vendor/data/fts.xlsx')
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

    def clients
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        family_name           = workbook.row(row)[headers['Family Name (English)']]
        given_name            = workbook.row(row)[headers['Given Name (English)']]
        local_family_name     = workbook.row(row)[headers['Family Name (Khmer)']]
        local_given_name      = workbook.row(row)[headers['Given Name (Khmer)']]
        gender          = workbook.row(row)[headers['Gender']]
        gender          = case gender
                          when 'Male' then 'male'
                          when 'Female' then 'female'
                          end
        dob                     = workbook.row(row)[headers['Date of Birth']]
        referral_source_id      = ReferralSource.find_or_create_by(name: (workbook.row(row)[headers['* Referral Source']])).try(:id)
        name_of_referee         = workbook.row(row)[headers['* Name of Referee']]
        referral_phone          = workbook.row(row)[headers['Referee Phone Number']]
        received_by_id          = User.find_by(first_name: workbook.row(row)[headers['* Referral Received By']]).try(:id)
        initial_referral_date   = workbook.row(row)[headers['* Initial Referral Date']]
        follow_up_by_id         = User.find_by(first_name: group_users(workbook.row(row)[headers['First Follow-Up By']]).first).try(:id)
        follow_up_date          = workbook.row(row)[headers['First Follow-Up Date']]
        user_ids                = User.where(first_name: group_users(workbook.row(row)[headers['* Case Worker / Staff']])).ids
        live_with               = workbook.row(row)[headers['Primary Carer Name']]
        telephone_number        = workbook.row(row)[headers['Primary Carer Phone Number']]
        current_province        = Province.find_by("name ilike ?", "%#{workbook.row(row)[headers['Current Province']]}%").try(:id) if workbook.row(row)[headers['Current Province']].present?
        district                = District.find_by("name ilike ?", "%#{workbook.row(row)[headers['Address - District/Khan']]}%").try(:id) if workbook.row(row)[headers['Address - District/Khan']].present?
        commune                 = workbook.row(row)[headers['Address - Commune/Sangkat']].squish
        village                 = workbook.row(row)[headers['Address - Village']]
        school_name             = workbook.row(row)[headers['School Name']]
        school_grade            = workbook.row(row)[headers['School Grade']].to_s
        Organization.switch_to 'shared'
        birth_province          = Province.find_by("name ilike ?", "%#{workbook.row(row)[headers['Client Birth Province']]}%").try(:id) if workbook.row(row)[headers['Client Birth Province']].present?
        Organization.switch_to 'fts'
        donor                   = Donor.find_by(code: workbook.row(row)[headers['Donor ID']])
        donor_id                = donor.present? ? donor.id : Donor.create(code: workbook.row(row)[headers['Donor ID']], name: workbook.row(row)[headers['Donor ID']]).id
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
          province_id: current_province,
          district_id: district,
          commune: commune,
          village: village,
          school_name: school_name,
          school_grade: school_grade,
          birth_province_id: birth_province,
          donor_ids: [donor_id],
          user_ids: user_ids
        )
        client.save(validate: false)
      end
    end

    def group_users(object)
      case object
      when 1
       %w(Daron Visal Kunthea Saify)
      when 2
        %w(Sophat Sourbona Chanda Sayorn)
      when 3
        %w(Sophanna Charadich Tong Ronouch)
      else
        object
      end
    end

    def donors
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        name            = workbook.row(row)[headers['*Donor ID']].squish
        code            = workbook.row(row)[headers['Code']].squish
        Donor.find_or_create_by(name: name, code: code)
      end
    end

    def users
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        first_name    = workbook.row(row)[headers['First Name']]
        last_name     = workbook.row(row)[headers['Last Name']]
        email         = workbook.row(row)[headers['*Email']]
        roles         = workbook.row(row)[headers['*Permission Level']].downcase
        password      = (('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a).sample(8).join

        user = User.new(first_name: first_name, last_name: last_name, email: email, password: password, roles: roles)
        user.save
      end
    end
  end
end
