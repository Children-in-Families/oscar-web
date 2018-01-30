module AghImporter
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = 'vendor/data/agh.xlsx')
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

    def families
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        name               = workbook.row(row)[headers['Name']]
        code               = workbook.row(row)[headers['Family ID']]
        family_type        = workbook.row(row)[headers['Family Type']].parameterize.underscore
        case_history       = workbook.row(row)[headers['Family History']]
        Family.create(name: name, code: code, case_history: case_history, family_type: family_type)
      end
    end

    def clients
      ((workbook.first_row + 1)..workbook.last_row).each do |row|

        family_name     = workbook.row(row)[headers['Last Name']] || ''
        given_name      = workbook.row(row)[headers['First Name']] || ''
        user_ids        = User.all.pluck(:id)
        kid_id          = workbook.row(row)[headers['Kid ID']]
        school_grade    = workbook.row(row)[headers['School Grade']]
        family_code     = workbook.row(row)[headers['Family ID']]
        donor_code      = workbook.row(row)[headers['Donor ID']]
        donor_id        = Donor.find_by(code: donor_code.split(',')[0]).try(:id) if donor_code.present?
        orphanage       = workbook.row(row)[headers['Has Been In Orphanage? (Yes/No)']].presence == 'Yes'
        gender          = workbook.row(row)[headers['Gender']]
        gender          =  case gender
                            when 'M' then 'male'
                            when 'F' then 'female'
                            end

        client = Client.new(
          user_ids: user_ids,
          family_name: family_name,
          given_name: given_name,
          gender: gender,
          kid_id: kid_id,
          school_grade: school_grade,
          donor_id: donor_id,
          has_been_in_orphanage: orphanage
        )
        client.save

        if family_code.present?
          family = Family.find_by(code: family_code)
          family.children << client.id
          family.save
        end
      end
    end

    def users
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        first_name = workbook.row(row)[headers['First Name']]
        last_name  = workbook.row(row)[headers['Last Name']]
        email      = workbook.row(row)[headers['Email']]
        roles      = workbook.row(row)[headers['Permission Level']].downcase
        password   = (('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a).sample(8).join

        User.create(first_name: first_name, last_name: last_name, email: email, password: password, roles: roles)
      end
    end

    def donors
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        donor_name        = workbook.row(row)[headers['Name']]
        code              = workbook.row(row)[headers['Donor ID']]
        description       = workbook.row(row)[headers['Description']]
        Donor.create(name: donor_name, code: code, description: description)
      end
    end
  end
end
