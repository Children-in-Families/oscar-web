class NgoUsageReport
  def initialize
  end

  def usage_report(date_time)
    import_usage_report(date_time)
  end

  private

  def import_usage_report(date_time)
    # column_names   = ['Organization','On-board Date', 'FCF', 'No. of Users', 'No. of Clients', 'No. Clients Added', 'No. Clients Deleted', 'No. of Logins/Month']

    ngo_columns    = ['Organization', 'On-board Date', 'FCF', 'Country']
    user_columns   = ['Organization', 'No. of Users', 'No. of Users Added', 'No. of Users Deleted', 'No. of Logins/Month']
    client_columns = ['Organization', 'No. of Clients', 'No. of Clients Added', 'No. of Clients Deleted', 'No. of Clients Transferred']

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

    ngo_worksheet      = book.create_worksheet(name: "NGO Report-#{previous_month}")
    user_worksheet     = book.create_worksheet(name: "User Report-#{previous_month}")
    client_worksheet   = book.create_worksheet(name: "Client Report-#{previous_month}")

    ngo_worksheet.insert_row(0, ngo_columns)
    user_worksheet.insert_row(0, user_columns)
    client_worksheet.insert_row(0, client_columns)

    ngo_length_of_column    = ngo_columns.length
    user_length_of_column   = user_columns.length
    client_length_of_column = client_columns.length

    #ngo_worksheet
    ngo_length_of_column.times do |i|
      ngo_worksheet.row(0).set_format(i, header_format)
    end

    ngo_worksheet.row(0).height = 30
    ngo_worksheet.column(0).width = 35
    ngo_worksheet.column(1).width = 33
    ngo_worksheet.column(2).width = 15
    ngo_worksheet.column(3).width = 20

    #user_worksheet
    user_length_of_column.times do |i|
      user_worksheet.row(0).set_format(i, header_format)
    end

    user_worksheet.row(0).height = 30
    user_worksheet.column(0).width = 35
    user_worksheet.column(1).width = 33
    user_worksheet.column(2).width = 15
    user_worksheet.column(3).width = 20
    user_worksheet.column(4).width = 20

    #client_worksheet
    client_length_of_column.times do |i|
      client_worksheet.row(0).set_format(i, header_format)
    end

    client_worksheet.row(0).height = 30
    client_worksheet.column(0).width = 35
    client_worksheet.column(1).width = 33
    client_worksheet.column(2).width = 15
    client_worksheet.column(3).width = 20
    client_worksheet.column(4).width = 20

    Organization.order(:created_at).each_with_index do |org, index|
      Organization.switch_to org.short_name
      ngo_name               = org.full_name
      ngo_on_board           = org.created_at.strftime("%B %d, %Y")
      fcf                    = org.fcf_ngo? ? 'Yes' : 'No'
      ngo_country            = Setting.country_name

      user_count             = User.non_devs.count
      previous_month_users   = PaperTrail::Version.where(item_type: 'User', created_at: beginning_of_month..end_of_month)
      user_added_count       = previous_month_users.where(event: 'create').count
      user_deleted_count     = previous_month_users.where(event: 'delete').count
      login_per_month        = Visit.excludes_non_devs.previous_month_logins.count

      client_count           = Client.count
      previous_month_clients = PaperTrail::Version.where(item_type: 'Client', created_at: beginning_of_month..end_of_month)
      client_added_count     = previous_month_clients.where(event: 'create').count
      client_deleted_count   = previous_month_clients.where(event: 'delete').count

      #in out
      tranferred_client_count =

      ngo_values             = [ngo_name, ngo_on_board, fcf, ngo_country]
      user_values            = [ngo_name, user_count, user_added_count, user_deleted_count, login_per_month]
      client_values          = [ngo_name, client_count, client_added_count, client_deleted_count, tranferred_client_count]

      ngo_worksheet.insert_row(index += 1, ngo_values)
      user_worksheet.insert_row(index += 1, user_values)
      client_worksheet.insert_row(index += 1, client_values)

      ngo_length_of_column.times do |i|
        ngo_worksheet.row(index).set_format(i, column_date_format) if i == 1
        next if i == 1
        ngo_worksheet.row(index).set_format(i, column_format)
      end

      user_length_of_column.times do |i|
        user_worksheet.row(index).set_format(i, column_date_format) if i == 1
        next if i == 1
        user_worksheet.row(index).set_format(i, column_format)
      end

      client_length_of_column.times do |i|
        client_worksheet.row(index).set_format(i, column_date_format) if i == 1
        next if i == 1
        client_worksheet.row(index).set_format(i, column_format)
      end

    end

    book.write("tmp/OSCaR-usage-report-#{date_time}.xls")
    generate(date_time, previous_month)
  end

  def generate(date_time, previous_month)
    NgoUsageReportWorker.perform_async(date_time, previous_month)
  end
end
