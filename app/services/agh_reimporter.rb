module AghReimporter
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = 'vendor/data/re_agh.xlsx')
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
        kid_id                = workbook.row(row)[headers['Kid ID']]
        family_name           = workbook.row(row)[headers['Last Name']] || ''
        given_name            = workbook.row(row)[headers['First Name']] || ''
        local_family_name     = workbook.row(row)[headers['Last Name (khmer)']] || ''
        local_given_name      = workbook.row(row)[headers['First Name (khmer)']] || ''
        gender                = workbook.row(row)[headers['Gender']]
        dob                   = workbook.row(row)[headers['Date of Birth']]
        school_name           = workbook.row(row)[headers['School Name']]
        school_grade          = workbook.row(row)[headers['School Grade']]
        birth_province        = workbook.row(row)[headers['*Birth Province']]
        Organization.switch_to 'shared'
        birth_province_id     = Province.where("name ilike ?", "%#{birth_province}%").first.try(:id) if birth_province.present?
        Organization.switch_to 'agh'
        current_province_value      = workbook.row(row)[headers['*Current Province']]
        current_province            = Province.where("name ilike ?", "%#{current_province_value}%").first if current_province_value.present?
        district                    = workbook.row(row)[headers['Current Address']]
        district_id                 = current_province.districts.where("name ilike ?", "%#{district}%").first.try(:id) if current_province.present? && district.present?
        follow_up_date              = workbook.row(row)[headers['Follow Up Date']]
        has_been_in_orphanage       = case workbook.row(row)[headers['Has Been In Orphanage?']]
                                      when 'Yes' then true
                                      when 'No' then false
                                      end
        has_been_in_government_care = case workbook.row(row)[headers['Has Been In Government Care?']]
                                      when 'Yes' then true
                                      when 'No' then false
                                      end
        user_ids                    = User.where(first_name: 'Chenda').pluck(:id)

        client = Client.find_by(kid_id: kid_id)
        if client.present?
          client.family_name = family_name
          client.given_name = given_name
          client.local_family_name = local_family_name
          client.local_given_name = local_given_name
          client.gender = gender
          client.date_of_birth = dob
          client.school_name = school_name
          client.school_grade = school_grade
          client.birth_province_id = birth_province_id
          client.province_id = current_province.try(:id)
          client.district_id = district_id
          client.follow_up_date = follow_up_date
          client.has_been_in_orphanage = has_been_in_orphanage
          client.has_been_in_government_care = has_been_in_government_care
          client.user_ids = user_ids
        else
          client = Client.new(
            kid_id: kid_id,
            family_name: family_name,
            given_name: given_name,
            local_given_name: local_given_name,
            local_family_name: local_family_name,
            gender: gender,
            date_of_birth: dob,
            school_name: school_name,
            school_grade: school_grade,
            birth_province_id: birth_province_id,
            province_id: current_province.try(:id),
            district_id: district_id,
            follow_up_date: follow_up_date,
            has_been_in_orphanage: has_been_in_orphanage,
            has_been_in_government_care: has_been_in_government_care,
            user_ids: user_ids
          )
        end
        client.save(validate: false)
      end
    end
  end
end
