module IcfImporter
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = 'vendor/data/icf.xlsx')
      @path     = path
      @workbook = Roo::Excelx.new(path)

      sheet_index = workbook.sheets.index(sheet_name)
      workbook.default_sheet = workbook.sheets[sheet_index]
      sheet_header
    end

    def sheet_header
      @headers = Hash.new
      workbook.row(1).each_with_index { |header, i| headers[header] = i }
    end

    def clients
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        user_id     = User.find_by(first_name: workbook.row(row)[headers['CW First Name']]).id
        donor_id    = Donor.find_by(code: workbook.row(row)[headers['Donor ID']]).try(:id)
        family_id   = Family.find_by(code: workbook.row(row)[headers['Family ID']]).id
        province_id = Province.find_by(name: workbook.row(row)[headers['Current Province']]).id

        kid_id                = workbook.row(row)[headers['Kid ID']]
        last_name             = workbook.row(row)[headers['Name']].partition(' ').first
        first_name            = workbook.row(row)[headers['Name']].partition(' ').last
        gender                = workbook.row(row)[headers['Gender']]
        gender                = case gender
                                when 'Male'   then 'male'
                                when 'Female' then 'female'
                                end
        dob                   = workbook.row(row)[headers['DoB']]
        current_address       = workbook.row(row)[headers['Current Address']]
        initial_referral_date = workbook.row(row)[headers['Initial Referral Date']]

        c = Client.new(
          kid_id: kid_id,
          first_name: first_name,
          last_name: last_name,
          gender: gender,
          date_of_birth: dob,
          current_address: current_address,
          initial_referral_date: initial_referral_date,
          province_id: province_id,
          state: 'accepted',
          user_id: user_id,
          donor_id: donor_id
        )
        c.save

        Case.create(client_id: c.id, case_type: 'FC', start_date: Date.today, family_id: family_id, user_id: c.user_id)
      end
    end

    def families
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        name         = workbook.row(row)[headers['Family Name']]
        code         = workbook.row(row)[headers['Family Code']]
        family_type  = workbook.row(row)[headers['Family Type']]
        case_history = workbook.row(row)[headers['Case History']]
        Family.create(name: name, code: code, family_type: family_type, case_history: case_history)
      end
    end

    def donors
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        name = workbook.row(row)[headers['Donor Name']]
        code = workbook.row(row)[headers['Donor Code']]
        Donor.create(name: name, code: code)
      end
    end

    def users
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        roles      = workbook.row(row)[headers['Roles']].downcase
        first_name = workbook.row(row)[headers['First Name']]
        last_name  = workbook.row(row)[headers['Last Name']]
        email      = workbook.row(row)[headers['Email']]
        password   = (0...8).map { (65 + rand(26)).chr }.join
        User.create(first_name: first_name, last_name: last_name, email: email, password: password, roles: roles)
      end
    end
  end
end
