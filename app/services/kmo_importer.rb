module KmoImporter
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = 'vendor/data/kmo.xlsx')
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
        user_first_name   = workbook.row(row)[headers['Case Worker Name']]
        user              = User.find_by(first_name: user_first_name)
        given_name        = workbook.row(row)[headers['First Name']]
        family_name       = workbook.row(row)[headers['Last Name']]
        local_given_name  = workbook.row(row)[headers['First Name (Local)']]
        local_family_name = workbook.row(row)[headers['Last Name (Local)']]
        gender            = workbook.row(row)[headers['Gender']]
        gender            =  case gender
                            when 'M' then 'male'
                            when 'F' then 'female'
                            end
        dob               = workbook.row(row)[headers['DoB']].to_s

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

        school_grade          = workbook.row(row)[headers['School Grade']]
        current_address       = workbook.row(row)[headers['Current Address']]
        birth_province        = workbook.row(row)[headers['Birth Province']]
        current_province      = workbook.row(row)[headers['Current Province']]
        birth_province_id     = Province.find_by(name: birth_province).try(:id)
        current_province_id   = Province.find_by(name: current_province).try(:id)
        initial_referral_date = workbook.row(row)[headers['Initial Referral Date']]
        kid_id                = workbook.row(row)[headers['Child ID']]
        user_id               = user.try(:id)

        client = Client.new(
          given_name: given_name,
          family_name: family_name,
          local_given_name: local_given_name,
          local_family_name: local_family_name,
          gender: gender,
          date_of_birth: dob,
          school_grade: school_grade,
          current_address: current_address,
          birth_province_id: birth_province_id,
          province_id: current_province_id,
          initial_referral_date: initial_referral_date,
          state: 'accepted',
          user_ids: [user_id],
          kid_id: kid_id
        )
        client.save
      end
    end

    def provinces
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        name = workbook.row(row)[headers['Name']]
        Province.find_or_create_by(name: name)
      end
    end

    def users
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        first_name = workbook.row(row)[headers['First Name']]
        email   = workbook.row(row)[headers['Email']]
        password   = (('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a).sample(8).join
        role    = workbook.row(row)[headers['Permission Level']]
        manager_name = workbook.row(row)[headers['Manager']] || ''
        manager_id = User.managers.find_by(first_name: manager_name).try(:id)
        User.create(first_name: first_name, email: email, password: password, roles: role, manager_id: manager_id)
      end
    end
  end
end
