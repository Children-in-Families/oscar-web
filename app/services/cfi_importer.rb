module CfiImporter
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = 'vendor/data/cfi_clients.xlsx')
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
        user                  = User.find_by(first_name: workbook.row(row)[headers['Case Worker']])
        given_name            = workbook.row(row)[headers['Given Name']]
        family_name           = workbook.row(row)[headers['Family Name']]
        gender                = case workbook.row(row)[headers['Gender']]
                                when 'M' then 'male'
                                when 'F' then 'female'
                                end
        dob                   = workbook.row(row)[headers['Date of Birth']]
        if dob.present?
          begin
            dob = Date.parse(dob.to_s)
          rescue ArgumentError
            dob = Date.strptime(dob, '%m/%d/%Y').to_s
          end
        end

        village               = workbook.row(row)[headers['Address (Village)']]
        kid_id                = workbook.row(row)[headers['Students ID']]
        live_with             = workbook.row(row)[headers['Who to live with']]
        poverty_certificate   = workbook.row(row)[headers['Poverty Certificate']] || 0
        rice_support          = workbook.row(row)[headers['Rice Support']] || 0
        family_code           = workbook.row(row)[headers['Family ID#']]
        family                = Family.find_by(code: family_code)
        c = Client.new(
          given_name: given_name,
          family_name: family_name,
          gender: gender,
          date_of_birth: dob,
          village: village,
          state: 'accepted',
          user: user,
          kid_id: kid_id,
          live_with: live_with,
          poverty_certificate: poverty_certificate,
          rice_support: rice_support
        )
        c.save
        c.cases.create(case_type: 'FC', start_date: Date.today, family: family, user_id: c.user_id)
      end
    end

    def families
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        code         = workbook.row(row)[headers['Family ID#']]
        family_name  = workbook.row(row)[headers['Family Name']]
        family_type  = workbook.row(row)[headers['Family Type']]
        Family.create(name: family_name, code: code, family_type: family_type)
      end
    end

    def users
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        first_name = workbook.row(row)[headers['First Name']]
        last_name  = workbook.row(row)[headers['Last Name']]
        roles      = workbook.row(row)[headers['Roles']]
        email      = workbook.row(row)[headers['Email']]
        password   = (('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a).sample(8).join

        manager_name       = workbook.row(row)[headers['Manager']]
        manager_first_name = ''
        manager_last_name  = ''
        if manager_name.present?
          manager_first_name = manager_name.split.first
          manager_last_name  = manager_name.split.last
        end

        manager_id = User.find_by(first_name: manager_first_name, last_name: manager_last_name)
        User.create(first_name: first_name, last_name: last_name, email: email, password: password, roles: roles, manager_id: manager_id)
      end
    end
  end
end
