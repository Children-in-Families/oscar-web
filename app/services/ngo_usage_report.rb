class NgoUsageReport
  def initialize
  end

  def usage_report(date_time)
    import_usage_report(date_time)
  end

  def import_usage_report(date_time)
    column_names = ['Organization Name', 'FCF', 'Users', 'Client', 'Login per month']
    book = Spreadsheet::Workbook.new
    worksheet = book.create_worksheet
    worksheet.insert_row(0, column_names)
    Organization.order(:created_at).each_with_index do |org, index|
      Organization.switch_to org.short_name
      ngo_name = org.full_name
      fcf = org.fcf_ngo? ? 'Yes' : 'No'
      client_count = Client.count
      user_count = User.count
      login_per_month = Visit.find_user_login_per_month.count
      values = [ngo_name, fcf, user_count, client_count, login_per_month]
      worksheet.insert_row(index += 1, values)
    end
    book.write("tmp/usage_report/cambodian-families-usage-report-#{date_time}.xlsx")
    generate(date_time)
  end

  def generate(date_time)
    NgoUsageReportWorker.perform_async(date_time)
  end
end
