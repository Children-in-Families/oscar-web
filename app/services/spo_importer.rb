module SpoImporter
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = 'vendor/data/sepheo.xlsx')
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
        case_workers     = workbook.row(row)[headers['Case Worker ID']]
        user_emails      = case_workers.split(', ')
        user_ids         = User.where(email: user_emails).ids

        given_name      = workbook.row(row)[headers['Given Name']]
        family_name     = workbook.row(row)[headers['Family Name']]
        gender          = workbook.row(row)[headers['Gender']]
        gender          =  case gender
                            when 'M' then 'male'
                            when 'F' then 'female'
                            end

        province_name          = workbook.row(row)[headers['Current Province']]
        province_id            = Province.find_by(name: province_name).try(:id)
        current_address        = workbook.row(row)[headers['Current Address']]
        relevent_referral_info = workbook.row(row)[headers['Relevant Referral Information']]
        initial_referral_date   = workbook.row(row)[headers['Initial Referral Date']]
        referral_phone         = workbook.row(row)[headers['Referral Phone']]

        client = Client.new(
          user_ids: user_ids,
          family_name: family_name,
          given_name: given_name,
          gender: gender,
          province_id: province_id,
          current_address: current_address,
          relevant_referral_information: relevent_referral_info,
          initial_referral_date: initial_referral_date,
          referral_phone: referral_phone,
          state: 'accepted'
        )
        client.save
      end
    end

    def users
      ((workbook.first_row + 1)..workbook.last_row).each do |row|

        first_name    = workbook.row(row)[headers['First Name']]
        last_name     = workbook.row(row)[headers['Last Name']]
        email         = workbook.row(row)[headers['Email']]
        manager_email = workbook.row(row)[headers['Manager']]
        roles         = workbook.row(row)[headers['Permission Level']].downcase
        password      = (('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a).sample(8).join

        manager_id    = User.find_by(email: manager_email).try(:id)

        user = User.new(first_name: first_name, last_name: last_name, email: email, password: password, roles: roles)
        user.manager_id = manager_id if manager_id.present?
        user.save
      end
    end

    def donors
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        donor_name = workbook.row(row)[headers['Name']]

        Donor.create(name: donor_name)
      end
    end
  end
end
