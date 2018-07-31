module TlcImporter
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = 'vendor/data/tlc.xlsx')
      @path     = path
      @workbook = Roo::Excelx.new(path)

      sheet_index = workbook.sheets.index(sheet_name)
      workbook.default_sheet = workbook.sheets[sheet_index]
      sheet_header
    end

    def sheet_header
      @headers = Hash.new
      workbook.row(5).each_with_index { |header, i|
        headers[header] = i
      }
    end

    def clients
      ((workbook.first_row + 5)..workbook.last_row).each do |row|
        family_name            = workbook.row(row)[headers['Family Name (English)']]
        given_name             = workbook.row(row)[headers['Given Name (English)']]
        local_family_name      = workbook.row(row)[headers['Family Name (Khmer)']]
        local_given_name       = workbook.row(row)[headers['Given Name (Khmer)']]
        gender                 = workbook.row(row)[headers['Gender']].downcase
        dob                    = format_date_of_birth(workbook.row(row)[headers['Date of Birth']].to_s)

        referral_source_id     = find_referral_source(workbook.row(row)[headers['* Referral Source']]).id
        referral_phone         = workbook.row(row)[headers['Referee Phone Number']]
        received_by_id         = find_user(workbook.row(row)[headers['Referral Received By']]).id
        initial_referral_date  = format_date_of_birth(workbook.row(row)[headers['* Initial Referral Date']].to_s)
        name_of_referee        = workbook.row(row)[headers['Name of Referee']]
        user_id                = find_user(workbook.row(row)[headers['Case Worker / Staff']]).id

        current_province       = workbook.row(row)[headers['Current Province']].split('/').last.squish if workbook.row(row)[headers['Current Province']].present?
        current_province_id    = Province.where("name ilike ?", "%#{current_province}%").first.try(:id)
        district               = workbook.row(row)[headers['Address - District/Khan']]
        district_id            = District.where("name ilike ?", "%#{district}%").first.try(:id)
        commune                = workbook.row(row)[headers['Address - Commune/Sangkat']]
        village                = workbook.row(row)[headers['Address - Village']] == 'Unknown' ? '' : workbook.row(row)[headers['Address - Village']]
        house                  = workbook.row(row)[headers['Address - House#']] == 'Unknown' ? '' : workbook.row(row)[headers['Address - House#']]
        street                 = workbook.row(row)[headers['Address - Street']] == 'Unknown' ? '' : workbook.row(row)[headers['Address - Street']]

        donor                  = workbook.row(row)[headers['Donor']]
        donor_id               = Donor.find_by(name: donor).id
        rated_for_id_poor      = workbook.row(row)[headers['Is the Client Rated for ID Poor?']]
        code                   = workbook.row(row)[headers['Custom ID Number 1']]

        client = Client.new(
          family_name: family_name,
          given_name: given_name,
          local_family_name: local_family_name,
          local_given_name: local_given_name,
          gender: gender,
          date_of_birth: dob,
          referral_source_id: referral_source_id,
          referral_phone: referral_phone,
          received_by_id: received_by_id,
          initial_referral_date: initial_referral_date,
          name_of_referee: name_of_referee,
          user_ids: [user_id],
          province_id: current_province_id,
          district_id: district_id,
          commune: commune,
          village: village,
          street_number: street,
          house_number: house,
          donor_id: donor_id,
          rated_for_id_poor: rated_for_id_poor,
          code: code
        )
        client.save(validate: false)
      end
    end

    def format_date_of_birth(value)
      first_regex  = /\A\d{2}\/\d{2}\/\d{2}\z/
      second_regex = /\A\d{4}\z/
      ages = ['5', '6', '7', '8', '10', '37', '39']

      if value =~ first_regex
        value  = value.split('/')
        year = "20#{value.last}"
        value  = value.shift(2)
        value  = value.push(year)
        value  = value.join('-')
      elsif value =~ second_regex
        value = "01-01-#{value}"
      elsif ages.include?(value)
        value = value.to_i.years.ago.to_date
      end
      value
    end

    def find_referral_source(value)
      ReferralSource.find_or_create_by(name: value)
    end

    def find_user(value)
      last_name = value.split(' ').last
      last_name = last_name == 'Seourn' ? 'Soeurn' : last_name
      User.find_by(last_name: last_name)
    end
  end
end
