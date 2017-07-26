module AhcImporter
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = 'vendor/data/ahc.xlsx')
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
        user_name       = workbook.row(row)[headers['Case Worker ID']]
        user_first_name = user_name.split().first
        user_last_name  = user_name.split().last
        user            = User.find_by(first_name: user_first_name, last_name: user_last_name)
        
        client_name     = workbook.row(row)[headers['Given Name']]
        family_name     = client_name.split().first
        given_name      = client_name.split().last
        gender          = workbook.row(row)[headers['Gender']]
        gender          =  case gender
                            when 'M' then 'male'
                            when 'F' then 'female'
                            end
        dob             = workbook.row(row)[headers['DoB']]
        dob             = dob.to_date if dob.present?
        
        initial_referral_date = workbook.row(row)[headers['Initial Referral Date']]
        initial_referral_date = initial_referral_date.to_date if initial_referral_date.present?

        kid_id      = workbook.row(row)[headers['Kid ID']]
        province    = Province.find_by(name: workbook.row(row)[headers['Current Province']])
        province_id = province.id if province.present?

        client = Client.new(
          user_ids: [user.id],
          family_name: family_name,
          given_name: given_name,
          gender: gender,
          date_of_birth: dob,
          initial_referral_date: initial_referral_date,
          kid_id: kid_id,
          province_id: province_id,
          state: 'accepted'
        )
        client.save
      end
    end

    def users
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        first_name = workbook.row(row)[headers['First Name']]
        last_name  = workbook.row(row)[headers['Last Name']]
        email      = workbook.row(row)[headers['Email']]
        roles      = workbook.row(row)[headers['Permission Level']].downcase
        password   = (('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a).sample(8).join

        User.create(first_name: first_name, last_name: last_name, email: email, password: password, roles: roles)
      end
    end

    def donors
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        donor_name = workbook.row(row)[headers['Donor Name']]
        code       = workbook.row(row)[headers['Donor ID']]
        Donor.create(name: donor_name, code: code)
      end
    end
  end
end
