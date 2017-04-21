module CctImporter
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = 'vendor/data/cct.xlsx')
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
        user_first_name  = workbook.row(row)[headers['Case Worker']]
        user             = User.find_by(first_name: user_first_name)
        given_name       = workbook.row(row)[headers['Given Name']]
        family_name      = workbook.row(row)[headers['Family Name']]
        local_given_name = workbook.row(row)[headers['Local Given Name']]
        gender           = workbook.row(row)[headers['Gender']]
        gender           =  case gender
                            when 'M' then 'male'
                            when 'F' then 'female'
                            end
        dob              = workbook.row(row)[headers['DoB']].to_s
        
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
        
        current_address  = workbook.row(row)[headers['Current Address']]
        user_id          = user.id

        client = Client.new(
          given_name: given_name,
          family_name: family_name,
          local_given_name: local_given_name,
          gender: gender,
          date_of_birth: dob,
          current_address: current_address,
          state: 'accepted',
          user_id: user_id
        )
        client.save
      end
    end

    def users
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        first_name = workbook.row(row)[headers['First Name']]
        email      = "#{first_name.gsub(/\s+/, '').downcase}@cambodianchildrenstrust.org"
        role       = workbook.row(row)[headers['Role']]
        User.create(first_name: first_name, email: email, password: '12345678', roles: role)
      end
    end
  end
end
