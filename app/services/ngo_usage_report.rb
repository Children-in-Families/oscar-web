class NgoUsageReport
  def initialize
  end

  def usage_report(date_time)
    import_usage_report(date_time)
  end

  private

  def import_usage_report(date_time)
    column_names   = ['Organization', 'FCF', 'No. of Users', 'No. of Clients', 'No. of Logins/Month']
    book           = Spreadsheet::Workbook.new
    header_format = Spreadsheet::Format.new(
      horizontal_align: :center,
      vertical_align: :center,
      shrink: true,
      border: :thin,
      size: 11
    )
    column_format = Spreadsheet::Format.new(
      shrink: true,
      border: :thin,
      size: 11
    )
    previous_month = 1.month.ago.strftime('%B %Y')
    worksheet      = book.create_worksheet(name: previous_month)
    worksheet.insert_row(0, column_names)
    length_of_column = column_names.length
    length_of_column.times do |i|
      worksheet.row(0).set_format(i, header_format)
    end
    worksheet.row(0).height = 30
    worksheet.column(0).width = 35
    worksheet.column(1).width = 15
    worksheet.column(2).width = 20
    worksheet.column(3).width = 20
    worksheet.column(4).width = 25
    Organization.order(:created_at).each_with_index do |org, index|
      Organization.switch_to org.short_name
      ngo_name        = org.full_name
      fcf             = org.fcf_ngo? ? 'Yes' : 'No'
      client_count    = Client.count
      user_count      = User.count
      login_per_month = Visit.previous_month_logins.count
      values          = [ngo_name, fcf, user_count, client_count, login_per_month]
      worksheet.insert_row(index += 1, values)
      length_of_column.times do |i|
        worksheet.row(index).set_format(i, column_format)
      end
    end
    book.write("tmp/OSCaR-usage-report-#{date_time}.xls")
    generate(date_time, previous_month)
  end

  def generate(date_time, previous_month)
    NgoUsageReportWorker.perform_async(date_time, previous_month)
  end
end
