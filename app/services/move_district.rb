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
          district_name  = workbook.row(row)[headers['District']]
          province_name = workbook.row(row)[headers['Province']].split(' / ').last
          if district_name.present?
            province = Province.find_by('provinces.name iLIKE ?', "%#{province_name}%")
            District.find_or_create_by(province: province, name: district_name) if province.present?
          end
        end
      end
    end

    def update_district_in_client
      Organization.where.not(short_name: ['spo', 'cps', 'kmo']).each do |org|
        Organization.switch_to org.short_name
        Client.where.not(archive_district: '').each do |client|
          if client.archive_district == 'Thmorkol'
            name = 'ថ្មគោល'
          elsif client.archive_district == 'ចម្ការមន'
            name = 'ចំការមន'
          elsif client.archive_district == 'ស្រុកមេសាង'
            name = 'មេសាង'
          elsif client.archive_district == 'ស្រុកសង្កែ​ '
            name = 'សង្កែ'
          elsif client.archive_district == 'ស្រុកស្វាយរៀង'
            name = 'ស្វាយរៀង'
          elsif client.archive_district == 'កំពុងលែង'
            name = 'កំពង់លែង'
          elsif client.archive_district == 'Dangnkao'
            name = 'ដង្កោ'
          elsif client.archive_district == 'ឈឺទាល'
            name = 'ឈើទាល'
          elsif client.archive_district == 'កំពងត្របែក'
            name = 'កំពង់ត្របែក'
          elsif client.archive_district == 'ពញក្រែក'
            name = 'ពញាក្រែក'
          elsif client.archive_district == 'Daun Penh'
            name = 'ដូនពេញ'
          elsif ['Sen Sok'].include?(client.archive_district)
            name = 'សែនសុខ'
          elsif ['Chbar Ompov', 'ច្បាអំពៅ'].include?(client.archive_district)
            name = 'ច្បារអំពៅ'
          elsif ['Ang Snuol', 'អង្គស្នូល'].include?(client.archive_district)
            name = 'អង្គស្នួល'
          elsif ['ស្វាយជ្រំ', 'ស្វាយជ្រុំ'].include?(client.archive_district)
            name = 'ស្វាយជ្រុំ'
          elsif ['Prek Phnov', 'ព្រៃព្នៅ'].include?(client.archive_district)
            name = 'ព្រែកព្នៅ'
          elsif ["\tពញាឮ", '	ពញាឮ'].include?(client.archive_district)
            name = 'ពញាឮ'
          elsif ['ក្រុងសៀមរាប', 'Siem Reap', 'Ream Reap'].include?(client.archive_district)
            name = 'សៀមរាប'
          elsif ['Mean Chey','Meanchey', 'Mean Chey '].include?(client.archive_district)
            name = 'មានជ័យ'
          elsif ['ស្រុកស្វាយជ្រុំ', 'ស្វាយជ្រំ', 'ស្រុកស្វាយជ្រំ'].include?(client.archive_district)
            name = 'ស្វាយជ្រុំ'
          elsif  ['Ek Phnom', 'Ekphnom', 'EK Phnum', 'Ek phom', 'Ek Phnum'].include?(client.archive_district)
            name = 'ឯកភ្នំ'
          elsif ['Battambaang', 'Battambang', 'បាត់បង', 'ក្រុុងបាត់ដំបង','ក្រុុង បាត់ដំបង', 'Battambang ', 'Battambaang ', 'បាតដំបង', 'ក្រុងបាត់ដំបង'].include?(client.archive_district)
            name = 'បាត់ដំបង'
          elsif ['Sihanouk ville', 'Sihanoukvill', 'Sihanoukvill', 'Sihanouk vill', 'Sihanouk '].include?(client.archive_district)
            name = 'Sihanouk Ville'
          else
            name = client.archive_district
          end
          district = District.find_by(name: name, province: client.province) if client.province.present?
          client.update_columns(district_id: district.id) if district.present?
        end
      end
    end
  end
end
