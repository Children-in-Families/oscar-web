module VoiceImporter
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = 'vendor/data/voice.xlsx')
      @path     = path
      @workbook = Roo::Excelx.new(path)
      sheet_index = workbook.sheets.index(sheet_name)
      workbook.default_sheet = workbook.sheets[sheet_index]
      sheet_header(sheet_index)
    end

    def sheet_header(sheet_index)
      @headers = Hash.new
      if sheet_index == 0
        workbook.row(5).each_with_index { |header, i|
          headers[header] = i
        }
      else
        workbook.row(2).each_with_index { |header, i|
          headers[header] = i
        }
      end
    end

    def users
      ((workbook.first_row + 2)..workbook.last_row).each do |row|
        first_name = workbook.row(row)[headers['First Name']]
        last_name  = workbook.row(row)[headers['Last Name']]
        email      = workbook.row(row)[headers['*Email']]
        roles      = workbook.row(row)[headers['*Permission Level']].downcase
        password   = (('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a).sample(8).join
        User.create(first_name: first_name, last_name: last_name, email: email, password: password, roles: roles)
      end
    end

    def families
      ((workbook.first_row + 2)..workbook.last_row).each do |row|
        name               = workbook.row(row)[headers['*Name']]
        code               = workbook.row(row)[headers['*Family ID']]
        family = Family.new(name: name, code: code, family_type: '')
        family.save(validate: false)
      end
    end

    def clients
      ((workbook.first_row + 5)..workbook.last_row).each do |row|
        family_name       = workbook.row(row)[headers['Family Name (English)']] || ''
        given_name        = workbook.row(row)[headers['Given Name (English)']] || ''
        local_family_name = workbook.row(row)[headers['Family Name (Khmer)']] || ''
        local_given_name  = workbook.row(row)[headers['Given Name (Khmer)']] || ''
        date_of_birth     = format_date_of_birth(workbook.row(row)[headers['Date of Birth']].to_s || '')
        live_with         = workbook.row(row)[headers['Primary Carer Name']] || ''
        telephone_number  = workbook.row(row)[headers['Primary Carer Phone Number']] || ''
        province          = workbook.row(row)[headers['Current Province']]
        province_id       = Province.where("name ilike ?", "%#{province}%").first.try(:id)
        address           = workbook.row(row)[headers['Address - District/Khan']] || ''
        address           = address.split(',') if address.present?

        user_emails = Array.new
        user_ids    = Array.new
        district, commune, house_number, street_number, village = nil

        if row.between?(7,9) || row.between?(96, 99)
          street_number     = address[0]
          commune           = address[1]
          district          = address[2]
        elsif row.between?(16,19) || row.between?(27, 28) || row.between?(35, 38) || row == 126 || row.between?(216, 127)
          commune           = address[0]
          district          = address[1]
        elsif row.between?(22, 26)
          house_number      = address[0].split(' ').first
          street_number     = address[0].split(' ').second
          commune           = address[1]
          district          = address[2]
        elsif row.between?(30, 31) || row.between?(71, 75) || row.between?(119, 121) || row == 123 || row == 173 || row.between?(208, 215) || row.between?(218, 221) || row.between?(223,225)
          village           = address[0]
          commune           = address[1]
          district          = address[2]
        elsif row.between?(127, 133)
          house_number      = address[0]
          street_number     = address[1]
          village           = address[2]
          district          = address[3]
        elsif row.between?(136, 141) || row == 144
          district          = 'Por Senchey'
        elsif row.between?(147, 148)
          street_number     = address[0]
          village           = address[2]
          commune           = address[3]
          district          = address[4]
        elsif row.between?(149, 169)
          district          = 'Saensokh'
        elsif row.between?(170, 172) || row.between?(174, 191)
          district          = 'Tuol Kouk'
        elsif row == 201
          village           = address[0]
          district          = address[1]
        elsif row == 115
          district          = 'Sampov Lun'
        end

        street_number = street_number.gsub(/street|st.|st/i, '').squish if street_number.present?
        village       = village.gsub(/village/i, '').squish if village.present?
        commune       = commune.gsub(/commune/i, '').squish if commune.present?
        district_id   = District.where("name ilike ?", "%#{district.squish}%").first.try(:id) if district.present?

        school_name       = workbook.row(row)[headers['School Name']] || ''
        school_grade      = workbook.row(row)[headers['School Grade']] || ''
        province_name     = workbook.row(row)[headers['Client Birth Province']] || ''
        birth_province_id = Province.where("name ilike ?", "%#{province_name}%").first.try(:id)
        code              = workbook.row(row)[headers['Custom ID Number 1']] || ''
        user_hash         = {"CK": "chenda@voice.org.au", "TC": "theany@voice.org.au", "RK": "ravon@voice.org.au", "GL": "guechhong@voice.org.au", "KS": "kristy@voice.org.au", "SF": "sarah@voice.org.au"}
        case_workers      = workbook.row(row)[headers['* Case Worker / Staff']].split(',')

        case_workers.each do |case_worker|
          user_emails << user_hash[:"#{case_worker.squish}"]
        end
        user_emails.each do |user_email|
          user_ids << User.find_by(email: user_email).try(:id)
        end

        family_code       = workbook.row(row)[headers['Family ID']]
        gender            = workbook.row(row)[headers['Gender']]
        gender            =  case gender
                              when 'Male' then 'male'
                              when 'Female' then 'female'
                              end
        client = Client.new(
          family_name: family_name,
          given_name: given_name,
          local_family_name: local_family_name,
          local_given_name: local_given_name,
          date_of_birth: date_of_birth,
          live_with: live_with,
          telephone_number: telephone_number,
          province_id: province_id,
          school_name: school_name,
          school_grade: school_grade,
          birth_province_id: birth_province_id,
          code: code,
          gender: gender,
          user_ids: user_ids,
          district_id: district_id,
          commune: commune,
          house_number: house_number,
          street_number: street_number,
          village: village
        )
        client.save(validate: false)

        if family_code.present?
          family = Family.find_by(code: family_code)
          family.children << client.id
          family.save(validate: false)
        end
      end
    end

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
