module MhcImporter
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = "vendor/data/mhc.xlsx")
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
        given_name            = workbook.row(row)[headers['*First Name']]
        family_name           = workbook.row(row)[headers['*Last Name']]
        birth_province        = workbook.row(row)[headers['*Birth Province']]
        birth_province_id     = birth_province.present? ? Province.find_by(name: birth_province).id : nil
        current_province      = workbook.row(row)[headers['*Current Province']]
        current_province_id   = current_province.present? ? Province.find_by(name: current_province).id : nil
        gender                = case workbook.row(row)[headers['*Gender']]
                                when 'Male'   then 'male'
                                when 'Female' then 'female'
                                end
        relevant_referral_information = workbook.row(row)[headers['Relevant Referral Information']]
        user_id          = user.id

        client = Client.new(
          given_name: given_name,
          family_name: family_name,
          gender: gender,
          birth_province_id: birth_province_id,
          state: 'accepted',
          relevant_referral_information: relevant_referral_information,
          province_id: current_province_id,
          user_id: user_id
        )
        client.save
      end
    end
  end
end
