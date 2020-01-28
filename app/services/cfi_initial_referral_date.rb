module CfiInitialReferralDate
  class Import
    attr_accessor :path, :headers, :workbook

    def initialize(sheet_name, path = 'vendor/data/cfi_initial_referral_date.xlsx')
      @path     = path
      @workbook = Roo::Excelx.new(path)

      sheet_index = workbook.sheets.index(sheet_name)
      workbook.default_sheet = workbook.sheets[sheet_index]
      sheet_header
    end

    def sheet_header
      @headers = Hash.new
      workbook.row(1).each_with_index { |header, i| headers[header] = i }
    end

    def initial_referral_date
      ((workbook.first_row + 1)..workbook.last_row).each do |row|
        id = workbook.row(row)[headers['ID']]
        date = workbook.row(row)[headers['Initial Referral Date']]
        date = date.present? ? date : '2001-01-01'
        client = Client.find_by(slug: id.squish)
        client.initial_referral_date = date
        client.save(validate: false)

        puts "#{client.id} - #{client.initial_referral_date}"
      end
    end
  end
end
