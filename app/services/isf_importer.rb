module IsfImporter
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = 'vendor/data/isf.xlsx')
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
        given_name = workbook.row(row)[headers['Given Name (English)']]
        family_name = workbook.row(row)[headers['Family Name (English)']]
        local_given_name = workbook.row(row)[headers['Given Name (Khmer)']]
        local_family_name = workbook.row(row)[headers['Family Name (Khmer)']]
        gender = workbook.row(row)[headers['Gender']]
        gender =  case gender
                  when 'M' then 'male'
                  when 'F' then 'female'
                  else ''
                  end
        dob = workbook.row(row)[headers['Date of Birth']]
        dob = format_date_of_birth(dob) if dob.present?
        name_of_referee = workbook.row(row)[headers['Name of Referee']]
        province_id = Province.find_by(name: workbook.row(row)[headers['Current Province']]).try(:id)
        village = workbook.row(row)[headers['Address - Village']]

        current_org = Organization.current
        Organization.switch_to 'shared'
        birth_province_id = Province.find_by(name: workbook.row(row)[headers['Client Birth Province']]).try(:id)
        Organization.switch_to current_org.short_name

        case_workers = workbook.row(row)[headers['Case Workers']].split(', ')
        user_ids = User.where(email: case_workers).pluck(:id)
        client = Client.new(
          user_ids: user_ids,
          given_name: given_name,
          local_given_name: local_given_name,
          family_name: family_name,
          local_family_name: local_family_name,
          gender: gender,
          date_of_birth: dob,
          name_of_referee: name_of_referee,
          province_id: province_id,
          village: village,
          birth_province_id: birth_province_id
        )
        client.save(validate: false)
      end
    end

    def users
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        first_name = workbook.row(row)[headers['First Name']]
        last_name  = workbook.row(row)[headers['Last Name']]
        email      = workbook.row(row)[headers['Email']]
        roles      = workbook.row(row)[headers['Roles']].downcase
        password   = (('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a).sample(8).join
        manager_email = workbook.row(row)[headers['Manager Email']]
        manager_id = User.find_by(email: manager_email).try(:id)

        User.create(first_name: first_name, last_name: last_name, email: email, password: password, roles: roles, manager_id: manager_id)
      end
    end

    private

    def format_date_of_birth(value)
      first_regex  = /\A\d{2}\/\d{2}\/\d{2}\z/
      second_regex = /\A\d{4}\z/

      if value =~ first_regex
        value  = value.split('/')
        year = "20#{value.last}"
        value  = value.shift(2)
        value  = value.push(year)
        value  = value.join('-')
      elsif value =~ second_regex
        value = "01-01-#{value}"
      end
      value
    end
  end
end
