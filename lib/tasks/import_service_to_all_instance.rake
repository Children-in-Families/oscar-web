namespace :import_service_to_all_instance do
  desc "Import ProgramStreamService to all OSCaR instance"
  task update: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      sheet_name = 'Sheet1'
      data       = DateService.new(sheet_name, org.short_name)
      data.import
    end
    puts"Import all service is success!"
  end
end

class DateService
  attr_accessor :path, :headers, :workbook

  def initialize(sheet_name, org_name, path = 'vendor/data/services/service.xlsx')
    @path     = path
    @workbook = Roo::Excelx.new(path)
    @org_name = org_name
  end

  def import
    column_letters = ('A'..'Z').to_a
    header_letters = column_letters[0..12]
    Organization.switch_to @org_name
    header_letters.each do |letter|
      fields = workbook.column(letter)
      values = fields.compact
      value  = values.shift
      service = Service.find_or_create_by(name: value)
      values.each do |name|
        Service.find_or_create_by(name: name, parent_id: service.id)
      end
    end
  end
end
