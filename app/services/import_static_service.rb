module ImportStaticService
  class DateService
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, org_name, path = 'lib/devdata/services/service.xlsx')
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
end
