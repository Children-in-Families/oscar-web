module FsiImporter
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = 'vendor/data/fsi.xlsx')
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
        province              = Province.find_by(name: workbook.row(row)[headers['Current Province']])
        birth_province_id     = Province.find_by(name: workbook.row(row)[headers['Birth Province']]).id
        kid_id                = workbook.row(row)[headers['Kid ID']]
        family_code           = workbook.row(row)[headers['Family ID']]
        family                = Family.find_by(code: family_code)
        donor_code            = workbook.row(row)[headers['Donor ID']]
        donor                 = Donor.find_by(code: donor_code)
        gender                = case workbook.row(row)[headers['Gender']]
                                when 'Male' then 'male'
                                when 'Female' then 'female'
                                end
        dob                   = workbook.row(row)[headers['Date of Birth']]
        if dob.present?
          begin
            dob = Date.parse(dob.to_s)
          rescue ArgumentError
            dob = Date.strptime(dob, '%m/%d/%Y').to_s
          end
        end
        c = Client.new(
          given_name: given_name,
          family_name: family_name,
          gender: gender,
          date_of_birth: dob,
          state: 'accepted',
          user: user,
          kid_id: kid_id,
          birth_province_id: birth_province_id,
          province: province,
          donor: donor,
        )
        c.save
        c.cases.create(case_type: 'FC', start_date: Date.today, family: family, user_id: c.user_id)
      end
    end

    def families
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        code         = workbook.row(row)[headers['Family ID']]
        family_name  = workbook.row(row)[headers['Family Name']]
        family_type  = workbook.row(row)[headers['Family Type']]
        Family.create(name: family_name, code: code, family_type: family_type)
      end
    end

    def donors
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        code         = workbook.row(row)[headers['Donor ID']]
        family_name  = workbook.row(row)[headers['Name']]
        Donor.create(name: family_name, code: code)
      end
    end

    def users
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        first_name      = workbook.row(row)[headers['First Name']]
        last_name       = workbook.row(row)[headers['Last Name']]
        roles           = workbook.row(row)[headers['Roles']]
        email           = workbook.row(row)[headers['Email']]
        manager_name    = workbook.row(row)[headers['Manager']]
        manager_id      = User.find_by(first_name: manager_name).try(:id)
        password        = (('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a).sample(8).join
        User.create(first_name: first_name, last_name: last_name, email: email, password: password, roles: roles, manager_id: manager_id)
      end
    end

    def update_users
      emails = []
      User.all.each do |user|
        user.email = user.email.squish
        user.save(validate: false)
      end

      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        first_name      = workbook.row(row)[headers['First Name']]
        last_name       = workbook.row(row)[headers['Last Name']]
        email           = workbook.row(row)[headers['Email']].squish
        roles           = workbook.row(row)[headers['Permission Level']]
        manager_name    = workbook.row(row)[headers['Manager']]

        manager_id      = User.find_by(first_name: manager_name.split(' ').first.squish, last_name: manager_name.split(' ').last.squish ).try(:id) if manager_name.present?
        password        = (('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a).sample(8).join

        user = User.find_by(email: email)
        if user.present?
          emails << email
          user.update_attributes(first_name: first_name, last_name: last_name, roles: roles.downcase, manager_id: manager_id, email: email)
        else
          if first_name == 'Chhorn' && last_name == 'Rerm'
            User.find_by(first_name: first_name, last_name: last_name).update_attributes(first_name: first_name, last_name: last_name, roles: roles.downcase, manager_id: manager_id, email: email)
            emails << email
          else
            emails << email
            User.create(first_name: first_name, last_name: last_name, email: email, password: password, roles: roles.downcase, manager_id: manager_id)
          end
        end
      end

      User.all.each do |user|
        next if emails.include?(user.email) || user.email == ENV['OSCAR_TEAM_EMAIL']
        user.destroy
      end
    end
  end
end
