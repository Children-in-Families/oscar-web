class NgoUsageReport
  def initialize(date_time)
    client_and_user_count
    import_usage_report(date_time)
    generate(date_time)
  end

  def import_usage_report(date_time)
    column_names = ['Organization Name', 'FCF', 'Users', 'Client', 'Login per month']
    book = Spreadsheet::Workbook.new
    worksheet = book.create_worksheet

    worksheet.insert_row(0, ['Organization Name', 'FCF', 'Users', 'Client', 'Login per month'])
    worksheet.insert_row(1, [@ngo_name, 'Yes', @user_count, @client_count, 11111])
    book.write("cambodian-families-usage-report-#{date_time}.xlsx")
  end

  def client_and_user_count
    Organization.switch_to 'cif'
    @ngo_name = Organization.find_by(short_name: 'cif').full_name
    @client_count = Client.count
    @user_count = User.count
    @login = User.first.sign_in_count
  end

  def generate(date_time)
    NgoUsageReportWorker.perform_async(date_time)
  end
end
