module ImportStaticService
  class DateService
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = 'vendor/data/services/service.xlsx')
      @path     = path
      @workbook = Roo::Excelx.new(path)
    end

    def import
      column_letters = ('A'..'Z').to_a
      header_letters = column_letters[0..10]
      Organization.all.pluck(:short_name).each do |short_name|
        Organization.switch_to short_name
        header_letters.each do |letter|
          fields = workbook.column(letter)
          values = fields.compact
          value  = values.shift
          service = Service.create(name: value)
          values.each do |name|
            Service.create(name: name, parent_id: service.id)
          end
        end
      end
    end
  end
end
