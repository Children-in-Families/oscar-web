module MhcImporter
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = "vendor/data/mhc.xlsx")
      @path     = path
      @workbook = Roo::Excelx.new(path)

      sheet_index = workbook.sheets.index(sheet_name)
      workbook.default_sheet = workbook.sheets[sheet_index]
      sheet_header
    end

    def sheet_header
      @headers = {}
      workbook.row(1).each_with_index { |header, i| headers[header] = i }
    end

    def users
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        first_name = workbook.row(row)[headers['First Name']]
        last_name  = workbook.row(row)[headers['Last Name']]
        email      = workbook.row(row)[headers['Email']]
        password   = (('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a).sample(8).join
        role       = workbook.row(row)[headers['Permission Level']]
        User.create(first_name: first_name, last_name: last_name, email: email, password: "#{password}", roles: role)
      end
    end
  end
end
