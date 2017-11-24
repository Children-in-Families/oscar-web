module SccImporter
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = 'vendor/data/scc.xlsx')
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
        given_name            = workbook.row(row)[headers['First Name']]
        local_given_name      = workbook.row(row)[headers['First Name (Local)']]
        family_name           = workbook.row(row)[headers['Last Name']]
        local_family_name     = workbook.row(row)[headers['Last Name (Local)']]

        gender          = workbook.row(row)[headers['Gender']]
        gender          =  case gender
                            when 'ប' then 'male'
                            when 'ស' then 'female'
                            end
        
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

        school_name     = workbook.row(row)[headers['School Name']]
        school_grade    = workbook.row(row)[headers['School Grade']]
        email           = workbook.row(row)[headers['Case Worker ID']]
        user            = User.find_by(email: email)

        client = Client.new(
          user_ids: [user.id],
          family_name: family_name,
          local_family_name: local_family_name,
          given_name: given_name,
          local_given_name: local_given_name,
          gender: gender,
          date_of_birth: dob,
          school_name: school_name,
          school_grade: school_grade,
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

        existing_user = User.find_by(email: email)
        User.create(first_name: first_name, last_name: last_name, email: email, password: password, roles: roles) unless existing_user.present?
      end
    end
  end
end
