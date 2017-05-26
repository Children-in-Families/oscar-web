class NgoUsageReport
  def initialize
  end

  def usage_report(date_time)
    import_usage_report(date_time)
  end

  private

  def import_usage_report(date_time)
    column_names   = ['Organization', 'FCF', 'No. of Users', 'No. of Clients', 'No. of Logins']
    book           = Spreadsheet::Workbook.new
    previous_month = 1.month.ago.strftime('%B %Y')
    worksheet      = book.create_worksheet(name: previous_month)
    worksheet.insert_row(0, column_names)
    Organization.order(:created_at).each_with_index do |org, index|
      Organization.switch_to org.short_name
      ngo_name        = org.full_name
      fcf             = org.fcf_ngo? ? 'Yes' : 'No'
      client_count    = Client.count
      user_count      = User.count
      login_per_month = Visit.previous_month_logins.count
      values          = [ngo_name, fcf, user_count, client_count, login_per_month]
      worksheet.insert_row(index += 1, values)
    end
    book.write("tmp/usage_report/cambodian-families-usage-report-#{date_time}.xls")
    generate(date_time, previous_month)
  end

  def generate(date_time, previous_month)
    NgoUsageReportWorker.perform_async(date_time, previous_month)
  end
end
