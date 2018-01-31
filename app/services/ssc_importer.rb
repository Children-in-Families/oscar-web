module SscImporter
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = 'vendor/data/ssc.xlsx')
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
        first_name             = workbook.row(row)[headers['First Name']]
        family_name            = first_name.split(' ')[0]
        given_name             = first_name.split(' ')[1]
        local_first_name       = workbook.row(row)[headers['First Name (Local)']]
        local_family_name      = local_first_name.split(' ')[0]
        local_given_name       = local_first_name.split(' ')[1]
        gender                 = workbook.row(row)[headers['Gender']]
        gender                 =  case gender
                                  when 'ប' then 'male'
                                  when 'ស' then 'female'
                                  end
        school_name            = workbook.row(row)[headers['School Name']]
        school_grade           = workbook.row(row)[headers['School Grade']]
        commune                = workbook.row(row)[headers['Current Address']]
        telephone_number       = workbook.row(row)[headers['Telephone']]
        birth_province         = workbook.row(row)[headers['Birth Province']]
        birth_province_id      = Province.where("name ilike ?", "'%#{birth_province}%'").first.try(:id)
        users_email            = workbook.row(row)[headers['Case Worker ID']].split('&')
        user_ids               = User.where(email: users_email).pluck(:id)

        dob             = workbook.row(row)[headers['Date of Birth']].to_s
        first_regex  = /\A\d{2}\/\d{2}\/\d{2}\z/
        second_regex = /\A\d{4}\z/
        ages = ['5', '6', '7', '8', '10', '37', '39']

        if dob =~ first_regex
          dob  = dob.split('/')
          year = "20#{dob.last}"
          dob  = dob.shift(2)
          dob  = dob.push(year)
          dob  = dob.join('-')
        elsif dob =~ second_regex
          dob = "01-01-#{dob}"
        elsif ages.include?(dob)
          dob = dob.to_i.years.ago.to_date
        end

        client = Client.new(
          family_name: family_name,
          given_name: given_name,
          local_family_name: local_family_name,
          local_given_name: local_given_name,
          gender: gender,
          school_name: school_name,
          school_grade: school_grade,
          commune: current_address,
          telephone_number: telephone_number,
          birth_province_id: birth_province_id,
          user_ids: user_ids,
          date_of_birth: dob
        )
        client.save
      end
    end

    def users
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        first_name = workbook.row(row)[headers['First Name']]
        last_name  = workbook.row(row)[headers['Last Name']]
        email      = workbook.row(row)[headers['Email']]
        role       = workbook.row(row)[headers['Permission Level']].downcase
        User.create(first_name: first_name, last_name: last_name, email: email, password: '12345678', roles: role)
      end
    end

    def donors
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        name      = workbook.row(row)[headers['Name']]
        code      = workbook.row(row)[headers['Donor ID']]
        Donor.create(name: name, code: code)
      end
    end
  end
end
