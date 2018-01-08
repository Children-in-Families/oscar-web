class MoveDistrict
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(path = 'vendor/data/district.xlsx')
      @path     = path
      @workbook = Roo::Excelx.new(path)

      sheet_index = workbook.sheets.index('District')
      workbook.default_sheet = workbook.sheets[sheet_index]
      sheet_header
    end

    def sheet_header
      @headers = Hash.new
      workbook.row(1).each_with_index { |header, i| headers[header] = i }
    end

    def districts
      Organization.where.not(short_name: ['spo', 'cps', 'kmo']).each do |org|
        Organization.switch_to org.short_name
        ((workbook.first_row + 1)..workbook.last_row).each do |row|
          discrit_name  = workbook.row(row)[headers['District']]
          if org.short_name == 'demo'
            province_name = workbook.row(row)[headers['Province']].split(' / ').last
          else
            province_name = workbook.row(row)[headers['Province']]
          end
          if discrit_name.present?
            province = Province.find_by('provinces.name iLIKE ?', "%#{province_name}%")
            District.create(province: province, name: discrit_name)
          end
        end
      end
    end

    def update_district_in_client
      Organization.where.not(short_name: ['spo', 'cps', 'kmo']).each do |org|
        Organization.switch_to org.short_name
        Client.where.not(archive_district: '').each do |client|
          if client.archive_district == 'ថ្មគោល'
            name = 'Thmorkol'
          elsif client.archive_district == 'Ang Snuol'
            name = 'អង្គស្នូល'
          elsif client.archive_district == 'ចម្ការមន'
            name = 'ចំការមន'
          elsif client.archive_district == 'ស្រុកមេសាង'
            name = 'មេសាង'
          elsif client.archive_district == 'ស្រុកសង្កែ​ '
            name = 'សង្កែ'
          elsif client.archive_district == 'ស្វាយជ្រំ'
            name = 'ស្វាយជ្រុំ'
          elsif client.archive_district == 'ស្រុកស្វាយរៀង'
            name = 'ស្វាយរៀង'
          elsif client.archive_district == 'Chbar Ompov'
            name = 'ច្បារអំពៅ'
          elsif client.archive_district == 'កំពង់លែង'
            name = 'កំពុងលែង'
          elsif client.archive_district == 'Prek Phnov'
            name = 'ព្រៃព្នៅ'
          elsif ["\tពញាឮ", '	ពញាឮ'].include?(client.archive_district)
            name = 'ពញាឮ'
          elsif ['ក្រុងសៀមរាប', 'Siem Reap'].include?(client.archive_district)
            name = 'Thmorkol"'
          elsif ['Mean Chey','Meanchey'].include?(client.archive_district)
            name = 'មានជ័យ'
          elsif ['ស្រុកស្វាយជ្រុំ', 'ស្វាយជ្រំ'].include?(client.archive_district)
            name = 'ស្វាយជ្រុំ'
          elsif  ['ឯកភ្នំ', 'Ekphnom', 'EK Phnum'].include?(client.archive_district)
            name = 'Ek Phnom'
          elsif ['Battambaang', 'Battambang', 'Battambang', 'បាត់បង', 'ក្រុុងបាត់ដំបង','ក្រុុង បាត់ដំបង'].include?(client.archive_district)
            name = 'បាត់ដំបង'
          elsif ['Sihanouk ville', 'Sihanoukvill', 'Sihanoukvill', 'Sihanouk vill', 'Sihanouk '].include?(client.archive_district)
            name = 'Sihanouk Ville'
          else
            name = client.archive_district
          end
          district = District.find_by(name: name)
          client.update(district: district) if district.present?
        end
      end
    end
  end
end
