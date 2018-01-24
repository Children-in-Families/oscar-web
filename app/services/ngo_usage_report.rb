class NgoUsageReport
  def initialize
  end

  def usage_report(date_time)
    import_usage_report(date_time)
  end

  private

  def import_usage_report(date_time)
    column_names   = ['Organization','On-board Date', 'FCF', 'No. of Users', 'No. of Clients', 'No. Clients Added', 'No. Clients Deleted', 'No. of Logins/Month']
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
    column_date_format = Spreadsheet::Format.new(
      shrink: true,
      border: :thin,
      size: 11,
      number_format: 'mmmm d, yyyy'
    )

    beginning_of_month = 1.month.ago.beginning_of_month
    end_of_month       = 1.month.ago.end_of_month
    previous_month     = 1.month.ago.strftime('%B %Y')
    worksheet          = book.create_worksheet(name: previous_month)
    worksheet.insert_row(0, column_names)
    length_of_column   = column_names.length

    length_of_column.times do |i|
      worksheet.row(0).set_format(i, header_format)
    end

    worksheet.row(0).height = 30
    worksheet.column(0).width = 35
    worksheet.column(1).width = 33
    worksheet.column(2).width = 15
    worksheet.column(3).width = 20
    worksheet.column(4).width = 20
    worksheet.column(5).width = 35
    worksheet.column(6).width = 35
    worksheet.column(7).width = 25

    Organization.order(:created_at).each_with_index do |org, index|
      Organization.switch_to org.short_name
      ngo_name               = org.full_name
      ngo_on_board           = org.created_at.strftime("%B %d, %Y")
      fcf                    = org.fcf_ngo? ? 'Yes' : 'No'
      client_count           = Client.count
      user_count             = User.non_devs.count
      login_per_month        = Visit.excludes_non_devs.previous_month_logins.count
      previous_month_clients = PaperTrail::Version.where(item_type: 'Client', created_at: beginning_of_month..end_of_month)
      client_added_count     = previous_month_clients.where(event: 'create').count
      client_deleted_count   = previous_month_clients.where(event: 'delete').count
      values                 = [ngo_name, ngo_on_board, fcf, user_count, client_count, client_added_count, client_deleted_count, login_per_month]
      worksheet.insert_row(index += 1, values)
      length_of_column.times do |i|
        worksheet.row(index).set_format(i, column_date_format) if i == 1
        next if i == 1
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
