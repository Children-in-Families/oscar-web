module CfiImporter
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = 'vendor/data/cfi.xlsx')
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
        user_id               = workbook.row(row)[headers['Case Worker']].present? ? User.find_by(first_name: workbook.row(row)[headers['Case Worker']].downcase).id : nil
        gender                = case workbook.row(row)[headers['Gender']]
                                when 'M'   then 'male'
                                when 'F' then 'female'
                                end
        dob                   = workbook.row(row)[headers['Date of birth']].present? ? workbook.row(row)[headers['Date of birth']].to_s : ''
        village               = workbook.row(row)[headers['Address (Village)']]
        student_id            = workbook.row(row)[headers['Students ID']]
        live_with             = workbook.row(row)[headers['Who to live with']]
        poverty_certificate   = workbook.row(row)[headers['Poverty Certificate']].present? ? workbook.row(row)[headers['Poverty Certificate']] : 0
        rice_support          = workbook.row(row)[headers['Rice Support']].present? ? workbook.row(row)[headers['Rice Support']] : 0
        c = Client.new(
          gender: gender,
          date_of_birth: dob,
          village: village,
          state: 'accepted',
          user_id: user_id,
          student_id: student_id,
          live_with: live_with,
          poverty_certificate: poverty_certificate,
          rice_support: rice_support
        )
        c.save
      end
    end

    def users
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        roles      = workbook.row(row)[headers['Roles']].downcase
        first_name = workbook.row(row)[headers['First Name']].downcase
        last_name  = workbook.row(row)[headers['Last Name']].downcase
        email      = workbook.row(row)[headers['Email']]
        password   = (('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a).sample(8).join
        # binding.pry if workbook.row(row)[headers['Manager']].present?
        manager    = workbook.row(row)[headers['Manager']].present? ? User.find_by(first_name: workbook.row(row)[headers['Manager']].split.first.downcase).id : nil
        User.create(first_name: first_name, last_name: last_name, email: email, password: password, roles: roles, manager_id: manager)
      end
    end
  end
end
