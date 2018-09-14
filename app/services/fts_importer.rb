module FtsImporter
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path)
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
        family_name           = workbook.row(row)[headers['Family Name (English)']].squish
        given_name            = workbook.row(row)[headers['Given Name (English)']].squish
        dob                   = workbook.row(row)[headers['Date of Birth']]
        case_work_name        = workbook.row(row)[headers['* Case Worker / Staff']]
        current_province        = Province.find_by("name ilike ?", "%#{workbook.row(row)[headers['Current Province']].squish}%") if workbook.row(row)[headers['Current Province']].present?
        district                = current_province.districts.find_by("name ilike ?", "%#{workbook.row(row)[headers['Address - District/Khan']].squish}%") if workbook.row(row)[headers['Address - District/Khan']].present? && current_province.present?
        commune                 = district.communes.find_by(name_en: workbook.row(row)[headers['Address - Commune/Sangkat']].squish) if district.present? && workbook.row(row)[headers['Address - Commune/Sangkat']].present?
        village                 = commune.villages.find_by(name_en: workbook.row(row)[headers['Address - Village']].squish) if commune.present? && workbook.row(row)[headers['Address - Village']].present?
        code                    = workbook.row(row)[headers['Family ID']].squish
        if (given_name == 'Makara' && family_name == 'Meurn') || (given_name == 'Norng' && family_name == 'Poy') || (given_name == 'Pok' && family_name == 'Panha') || (given_name == 'Buk' && family_name == 'Pa') || (given_name == 'Heng' && family_name == 'Kan')
          clients = Client.given_name_like(given_name).family_name_like(family_name)
          clients.last.destroy if clients.count > 1
          client = clients.first
          client.code = code if code.present?
          client.province = current_province if current_province.present?
          client.district = district if district.present? && current_province.present?
          client.commune = commune if commune.present? && district.present? && current_province.present?
          client.village = village if village.present? && commune.present? && district.present? && current_province.present?
          client.save(validate: false)
        else
          client = Client.given_name_like(given_name).family_name_like(family_name).find_by(date_of_birth: dob)
          client.code = code if code.present?
          client.province = current_province if current_province.present?
          client.district = district if district.present? && current_province.present?
          client.commune = commune if commune.present? && district.present? && current_province.present?
          client.village = village if village.present? && commune.present? && district.present? && current_province.present?
          client.save(validate: false)
        end
        if case_work_name == 'Kongkea '
          client = Client.given_name_like(given_name).family_name_like(family_name).find_by(date_of_birth: dob)
          user = User.find_by(first_name: 'Kongkea')
          client.user_ids = [user.id]
          client.save(validate: false)
        end
      end
    end

    def donors
      Sponsor.destroy_all
      Donor.destroy_all
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        name                = workbook.row(row)[headers['*Donor ID']].squish
        client_family_name  = workbook.row(row)[headers['Last Name']].squish
        client_given_name   = workbook.row(row)[headers['*Name']].squish
        donor = Donor.find_or_create_by(name: name, code: name)
        client = Client.find_by(given_name: client_given_name, family_name: client_family_name)
        if client.donors.empty?
          donor_ids = [donor.id]
          client.donor_ids = donor_ids
        else
          donor_ids = client.donor_ids << donor.id
          client.donor_ids = donor_ids
        end
        client.save(validate: false)
      end
    end

    def update_case_work
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        family_name           = workbook.row(row)[headers['FAMILY NAME']].squish
        given_name            = workbook.row(row)[headers['FIRST NAME']].squish
        user                  = User.find_by(first_name: 'Vichheka', last_name: 'Kim')
        client = Client.find_by(given_name: given_name, family_name: family_name)
        client.user_ids = [user.id]
        client.save(validate: false)
      end
    end
  end
end
