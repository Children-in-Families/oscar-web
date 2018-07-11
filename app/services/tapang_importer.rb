module TapangImporter
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path)
      @path     = path
      @workbook = Roo::Excelx.new(path)
      sheet_index = workbook.sheets.index(sheet_name)
      workbook.default_sheet = workbook.sheets[sheet_index]
      sheet_header(sheet_index)
    end

    def sheet_header(sheet_index)
      @headers = Hash.new

      if @path.include?('vendor/data/mtp1.xlsx')
        if sheet_index == 0
          workbook.row(5).each_with_index { |header, i|
            headers[header] = i
          }
        else
          workbook.row(2).each_with_index { |header, i|
            headers[header] = i
          }
        end
      else
        if sheet_index == 0
          workbook.row(11).each_with_index { |header, i|
            headers[header] = i
          }
        else
          workbook.row(4).each_with_index { |header, i|
            headers[header] = i
          }
        end
      end
    end

    def starting_row
      if @path.include?('vendor/data/mtp1.xlsx')
        2
      else
        4
      end
    end

    def starting_row_sheet_1
      if @path.include?('vendor/data/mtp1.xlsx')
        5
      else
        11
      end
    end

    def users
      ((workbook.first_row + starting_row)..workbook.last_row).each do |row|
        first_name = workbook.row(row)[headers['First Name']]
        last_name  = workbook.row(row)[headers['Last Name']]
        email      = workbook.row(row)[headers['*Email']]
        roles      = workbook.row(row)[headers['*Permission Level']].downcase
        password   = (('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a).sample(8).join

        User.create_with(first_name: first_name, last_name: last_name, password: password, roles: roles).find_or_create_by(email: email)
      end
    end

    def families
      ((workbook.first_row + starting_row)..workbook.last_row).each do |row|
        name               = workbook.row(row)[headers['*Name']] || ''
        code               = workbook.row(row)[headers['*Family ID']] || ''
        family = Family.new(name: name, code: code, family_type: '')
        family.save(validate: false)
      end
    end

    def referral_sources
      ((workbook.first_row + starting_row)..workbook.last_row).each do |row|
        name               = workbook.row(row)[headers['*Name']] || ''
        referral_source = ReferralSource.new(name: name)
        referral_source.save
      end
    end

    def agencies
      ((workbook.first_row + starting_row)..workbook.last_row).each do |row|
        name   = workbook.row(row)[headers['*Name']] || ''
        agency = Agency.new(name: name)
        agency.save
      end
    end

    def clients
      ((workbook.first_row + starting_row_sheet_1)..workbook.last_row).each do |row|
        family_name, given_name, local_family_name, local_given_name = nil

        if @path.include?('vendor/data/mtp1.xlsx')
          full_name         = workbook.row(row)[headers['Given Name (English)']].split(' ')
          local_full_name   = workbook.row(row)[headers['Given Name (Khmer)']].split(' ')
          given_name        = full_name.last
          family_name       = full_name.first
          local_family_name = local_full_name.first
          local_given_name  = local_full_name.last
          received_by       = workbook.row(row)[headers['* Referral Received By']] || ''
          received_by       = received_by.split(' ').last if received_by.present?
          followed_up_by    = workbook.row(row)[headers['First Follow-Up By']] || ''
          followed_up_by    = followed_up_by.split(' ').last if followed_up_by.present?
        else
          family_name       = workbook.row(row)[headers['Family Name (English)']] || ''
          given_name        = workbook.row(row)[headers['Given Name (English)']] || ''
          local_family_name = workbook.row(row)[headers['Family Name (Khmer)']] || ''
          local_given_name  = workbook.row(row)[headers['Given Name (Khmer)']] || ''
          received_by       = workbook.row(row)[headers['* Referral Received By']] || ''
          followed_up_by    = workbook.row(row)[headers['First Follow-Up By']] || ''
        end

        received_by_id    = User.where("first_name ilike ?", "%#{received_by}%").first.try(:id) if received_by.present?
        followed_up_by_id = User.where("first_name ilike ?", "%#{followed_up_by}%").first.try(:id) if followed_up_by.present?
        gender            = workbook.row(row)[headers['Gender']]
        gender            =  case gender
                              when 'Male' then 'male'
                              when 'Female' then 'female'
                              end
        date_of_birth     = format_date_of_birth(workbook.row(row)[headers['Date of Birth']].to_s || '')
        referral          = workbook.row(row)[headers['* Referral Source']] || ''
        name_of_referee   = workbook.row(row)[headers['* Name of Referee']] || ''
        referral_phone    = workbook.row(row)[headers['Referee Phone Number']] || ''
        follow_up_date    = workbook.row(row)[headers['First Follow-Up Date']] || ''
        live_with         = workbook.row(row)[headers['Primary Carer Name']] || ''
        telephone_number  = workbook.row(row)[headers['Primary Carer Phone Number']] || ''
        province          = workbook.row(row)[headers['Current Province']]
        province_id       = Province.where("name ilike ?", "%#{province}%").first.try(:id) if province.present?
        commune           = workbook.row(row)[headers['Address - Commune/Sangkat']] || ''
        house_number      = workbook.row(row)[headers['Address - House#']] || ''
        street_number     = workbook.row(row)[headers['Address - Street']] || ''
        village           = workbook.row(row)[headers['Address - Village']] || ''
        school_name       = workbook.row(row)[headers['School Name']] || ''
        school_grade      = workbook.row(row)[headers['School Grade']] || ''
        province_name     = workbook.row(row)[headers['Client Birth Province']] || ''
        birth_province_id = Province.where("name ilike ?", "%#{province_name}%").first.try(:id) if province_name.present?

        main_school_contact   = workbook.row(row)[headers['Main School Contact']] || ''
        referral_source_id    = ReferralSource.where("name ilike ?", "%#{referral}%").first.try(:id) if referral.present?
        initial_referral_date = workbook.row(row)[headers['* Initial Referral Date']] || ''

        commune = commune.to_s.gsub(/សង្កាត់|sangkat/i,'').squish if commune.present?
        village = village.to_s.gsub(/ភូមិ|vilang|villang|phum/i,'').squish if village.present?

        agencies          = workbook.row(row)[headers['Other Agencies Involved']] || ''
        agency_ids = []
        if agencies.present?
          agencies = agencies.split(',')
          agencies.each do |agency|
            agency_id = Agency.where("name ilike ?", "%#{agency.squish}%").first.try(:id)
            agency_ids << agency_id if agency_id.present?
          end
        end

        rated_for_id_poor = workbook.row(row)[headers['Is the Client Rated for ID Poor?']] || ''
        relevant_referral_information = workbook.row(row)[headers['Relevant Referral Information / Notes']] || ''

        user_emails = Array.new
        user_ids    = Array.new
        user_hash         = { "ORCO01": "",
                              "ORCO02": "",
                              "CP01": "",
                              "CP02": "",
                              "CP03": "",
                              "CP04": "",
                              "CP05": ""
                            }

        case_workers      = workbook.row(row)[headers['*Case Worker ID']]

        if case_workers.present?
          case_workers = case_workers.split(',')

          case_workers.each do |case_worker|
            user_emails << user_hash[:"#{case_worker.squish}"]
          end
        end

        if user_emails.present?
          user_emails.each do |user_email|
            user_ids << User.find_by(email: user_email).try(:id)
          end
        end

        family_code       = workbook.row(row)[headers['Family ID']]

        client = Client.new(
          family_name: family_name,
          given_name: given_name,
          local_family_name: local_family_name,
          local_given_name: local_given_name,
          gender: gender,
          date_of_birth: date_of_birth,
          name_of_referee: name_of_referee,
          referral_phone: referral_phone,
          received_by_id: received_by_id,
          initial_referral_date: initial_referral_date,
          followed_up_by_id: followed_up_by_id,
          follow_up_date: follow_up_date,
          live_with: live_with,
          telephone_number: telephone_number,
          province_id: province_id,
          commune: commune,
          house_number: house_number,
          street_number: street_number,
          village: village,
          school_name: school_name,
          school_grade: school_grade,
          main_school_contact: main_school_contact,
          birth_province_id: birth_province_id,
          relevant_referral_information: relevant_referral_information,
          user_ids: user_ids,
          rated_for_id_poor: rated_for_id_poor,
          referral_source_id: referral_source_id,
          agency_ids: agency_ids
        )
        client.save(validate: false)

        if family_code.present?
          family = Family.find_by(code: family_code)
          if family.present?
            family.children << client.id
            family.save(validate: false)
          end
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
