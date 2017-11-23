module CpsImporter
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = 'vendor/data/cps.xlsx')
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
        
        given_name                = workbook.row(row)[headers['Given Name']]
        gender                    = workbook.row(row)[headers['Gender']]
        gender                    = gender.downcase if gender.present?
        current_address           = workbook.row(row)[headers['Current Address']]
        school_name               = workbook.row(row)[headers['School Name']]
        school_grade              = workbook.row(row)[headers['School Grade']].to_s
        kid_id                    = workbook.row(row)[headers['Kid ID']]
        family_code               = workbook.row(row)[headers['Family ID']]
        user_email                = workbook.row(row)[headers['Case Worker ID']]
        user_ids                  = User.find_by(email: user_email).try(:id)
        has_been_in_orphanage     = workbook.row(row)[headers['Has Been In Orphanage?']]
        has_been_in_orphanage     = case has_been_in_orphanage
                                    when 'Yes' then true
                                    when 'No' then false
                                    end
        has_been_in_government_care     = workbook.row(row)[headers['Has Been In Government Care?']]
        has_been_in_government_care     = case has_been_in_government_care
                                          when 'Yes' then true
                                          when 'No' then false
                                          end
        relevant_referral_information     = workbook.row(row)[headers['Relevant Referral Information']]
        
        
        birth_province    = workbook.row(row)[headers['Birth Province']]
        birth_province_id = Province.find_by(name: birth_province).try(:id)

        current_province = workbook.row(row)[headers['Current Province']]
        province_id      = Province.find_by(name: current_province).try(:id)

        dob                     = workbook.row(row)[headers['Date of Birth']].to_s
        follow_up_date          = workbook.row(row)[headers['Follow Up Date']].to_s
        initial_referral_date   = workbook.row(row)[headers['Initial Referral Date']].to_s
        
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
          given_name: given_name,
          gender: gender,
          current_address: current_address,
          school_name: school_name,
          school_grade: school_grade,
          kid_id: kid_id,
          has_been_in_orphanage: has_been_in_orphanage,
          has_been_in_government_care: has_been_in_government_care,
          relevant_referral_information: relevant_referral_information,
          birth_province_id: birth_province_id,
          province_id: province_id,
          follow_up_date: follow_up_date,
          initial_referral_date: initial_referral_date,
          date_of_birth: dob,
        )
        client.user_ids   = [user_ids] if user_ids.present?
        client.save

        if family_code.present?
          family = Family.find_by(code: family_code)
          family.children << client.id
          family.save
        end
      end
    end

    def provinces
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        name = workbook.row(row)[headers['Name']]
        Province.find_or_create_by(name: name)
      end
    end

    def donors
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        name            = workbook.row(row)[headers['Name']]
        code            = workbook.row(row)[headers['Donor ID']]
        description     = workbook.row(row)[headers['Description']]

        Donor.find_or_create_by(name: name, code: code, description: description)
      end
    end

    def users
      ((workbook.first_row + 1)..workbook.last_row).each do |row|

        first_name    = workbook.row(row)[headers['First Name']]
        last_name     = workbook.row(row)[headers['Last Name']]
        email         = workbook.row(row)[headers['Email']]
        roles         = workbook.row(row)[headers['Permission Level']].downcase
        manager_id    = User.find_by(roles: 'manager').try(:id)
        password      = (('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a).sample(8).join

        user = User.new(first_name: first_name, last_name: last_name, email: email, password: password, roles: roles)
        user.manager_id = manager_id if roles == 'case worker'
        user.save
      end
    end

    def families
      ((workbook.first_row + 1)..workbook.last_row).each do |row|

        name          = workbook.row(row)[headers['Name']]       
        code          = workbook.row(row)[headers['Family ID']]
        case_history  = workbook.row(row)[headers['Family History']]
        family_type   = workbook.row(row)[headers['Family Type']].downcase.parameterize.underscore

        Family.find_or_create_by(name: name, code: code, case_history: case_history, family_type: family_type)
      end
    end
  end
end
