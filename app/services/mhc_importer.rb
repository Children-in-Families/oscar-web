module MhcImporter
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = "vendor/data/mhc_clients.xlsx")
      @path     = path
      @workbook = Roo::Excelx.new(path)

      sheet_index = workbook.sheets.index(sheet_name)
      workbook.default_sheet = workbook.sheets[sheet_index]
      sheet_header
    end

    def sheet_header
      @headers = {}
      workbook.row(1).each_with_index { |header, i| headers[header] = i }
    end

    def users
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        first_name = workbook.row(row)[headers['First Name']]
        last_name  = workbook.row(row)[headers['Last Name']]
        email      = workbook.row(row)[headers['Email']]
        password   = (('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a).sample(8).join
        role       = workbook.row(row)[headers['Permission Level']].downcase
        User.create(first_name: first_name, last_name: last_name, email: email, password: "#{password}", roles: role)
      end
    end

    def clients
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        user_first_name       = workbook.row(row)[headers['Case Worker ID']]
        user                  = User.find_by(first_name: user_first_name)
        given_name            = workbook.row(row)[headers['Given Name']]
        family_name           = workbook.row(row)[headers['Family Name']]
        birth_province        = workbook.row(row)[headers['Birth Province']]
        birth_province_id     = Province.find_by(name: birth_province).try(:id)
        province_name         = workbook.row(row)[headers['Current Province']]
        current_province      = Province.find_by(name: province_name)
        gender                = case workbook.row(row)[headers['Gender']]
                                when 'Male'   then 'male'
                                when 'Female' then 'female'
                                end
        relevant_referral_information = workbook.row(row)[headers['Relevant Referral Information']]

        client = Client.new(
          given_name: given_name,
          family_name: family_name,
          gender: gender,
          birth_province_id: birth_province_id,
          state: 'accepted',
          relevant_referral_information: relevant_referral_information,
          province: current_province,
          user: user
        )
        client.save
      end
    end
  end
end
