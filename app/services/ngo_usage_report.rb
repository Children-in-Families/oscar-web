class NgoUsageReport
  def initialize
  end

  def usage_report(date_time)
    import_usage_report(date_time)
  end

  def ngo_info(org)
    country = Setting.first.present? ? Setting.first.country_name.downcase : ''
    {
      ngo_name: org.full_name,
      ngo_short_name: org.short_name,
      ngo_on_board: org.created_at.strftime("%d %B %Y"),
      fcf: org.fcf_ngo? ? 'Yes' : 'No',
      ngo_country: country.titleize
    }
  end

  def ngo_users_info(beginning_of_month, end_of_month)
    previous_month_users = PaperTrail::Version.where(item_type: 'User', created_at: beginning_of_month..end_of_month)
    {
      user_count: User.non_devs.count,
      user_added_count: previous_month_users.where(event: 'create').count,
      user_deleted_count: previous_month_users.where(event: 'destroy').count,
      # should use PaperTrail instead for the visits
      login_per_month: Visit.excludes_non_devs.total_logins(beginning_of_month, end_of_month).count
    }
  end

  def ngo_clients_info(beginning_of_month, end_of_month)
    previous_month_clients = PaperTrail::Version.where(item_type: 'Client', created_at: beginning_of_month..end_of_month)
    {
      client_count: Client.count,
      client_added_count: previous_month_clients.where(event: 'create').count,
      client_deleted_count: previous_month_clients.where(event: 'destroy').count
    }
  end

  def ngo_referrals_info(beginning_of_month, end_of_month)
    tranferred_clients = PaperTrail::Version.where(item_type: 'Referral', event: 'create', created_at: beginning_of_month..end_of_month)
    {
      tranferred_client_count: tranferred_clients.map{ |a| a.changeset.dig(:slug) && a.changeset[:slug][1] }.compact.uniq.count
    }
  end

  private

  def import_usage_report(date_time)
    ngo_columns    = ['Organization', 'On-board Date', 'FCF', 'Country']
    user_columns   = ['Organization', 'No. of Users', 'No. of Users Added', 'No. of Users Deleted', 'No. of Logins/Month']
    client_columns = ['Organization', 'No. of Clients', 'No. of Clients Added', 'No. of Clients Deleted', 'No. of Clients Transferred']
    learning_columns = ['Onboarding Date', '', '', '', '', '', 'Number of Logins', '', '']
    sub_learning_columns = ['Started Sharing This Month', '', 'Started Sharing This Month', '', 'Currently Sharing (All Time)', '', 'User', 'Organization Name', 'Login Count']

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

    ngo_worksheet      = book.create_worksheet(name: "NGO Records-#{previous_month}")
    user_worksheet     = book.create_worksheet(name: "User Report-#{previous_month}")
    client_worksheet   = book.create_worksheet(name: "Client Report-#{previous_month}")
    learning_worksheet = book.create_worksheet(name: "OSCaR Leaning Report-#{previous_month}")

    ngo_worksheet.insert_row(0, ngo_columns)
    user_worksheet.insert_row(0, user_columns)
    client_worksheet.insert_row(0, client_columns)

    #learning worksheet
    learning_worksheet.insert_row(0, learning_columns)
    learning_worksheet.insert_row(1, sub_learning_columns)
    sub_learning_columns.length.times do |i|
      learning_worksheet.row(0).set_format(i, header_format)
      learning_worksheet.row(1).set_format(i, header_format)
    end
    # merge_cells(start_row, start_col, end_row, end_col)
    learning_worksheet.merge_cells(0, 0, 0, 5)
    learning_worksheet.merge_cells(0, 6, 0, 8)
    learning_worksheet.merge_cells(1, 0, 1, 1)
    learning_worksheet.merge_cells(1, 2, 1, 3)
    learning_worksheet.merge_cells(1, 4, 1, 5)

    (0..(sub_learning_columns.size - 1)).each {|index| learning_worksheet.column(index).width = 20 }



    ngo_length_of_column    = ngo_columns.length
    user_length_of_column   = user_columns.length
    client_length_of_column = client_columns.length

    #ngo_sheet
    ngo_length_of_column.times do |i|
      ngo_worksheet.row(0).set_format(i, header_format)
    end

    ngo_worksheet.row(0).height   = 30
    ngo_worksheet.column(0).width = 35
    ngo_worksheet.column(1).width = 33
    ngo_worksheet.column(2).width = 15
    ngo_worksheet.column(3).width = 20

    #user_sheet
    user_length_of_column.times do |i|
      user_worksheet.row(0).set_format(i, header_format)
    end

    user_worksheet.row(0).height   = 30
    (0..4).each {|index| user_worksheet.column(index).width = 30 }

    #client_sheet
    client_length_of_column.times do |i|
      client_worksheet.row(0).set_format(i, header_format)
    end

    client_worksheet.row(0).height   = 30
    (0..4).each {|index| client_worksheet.column(index).width = 30 }

    shared_data       = []
    stop_sharing_date = []
    all_learning_data = []

    Organization.order(:created_at).without_shared.each_with_index do |org, index|
      Organization.switch_to org.short_name

      setting                = ngo_info(org)
      ngo_users              = ngo_users_info(beginning_of_month, end_of_month)
      ngo_clients            = ngo_clients_info(beginning_of_month, end_of_month)
      ngo_referrals          = ngo_referrals_info(beginning_of_month, end_of_month)

      ngo_values             = [setting[:ngo_name], setting[:ngo_on_board], setting[:fcf], setting[:ngo_country]]
      user_values            = [setting[:ngo_name], ngo_users[:user_count], ngo_users[:user_added_count], ngo_users[:user_deleted_count], ngo_users[:login_per_month]]
      client_values          = [setting[:ngo_name], ngo_clients[:client_count], ngo_clients[:client_added_count], ngo_clients[:client_deleted_count], ngo_referrals[:tranferred_client_count]]

      start_sharing_data     = Setting.first.start_sharing_this_month(date_time)
      stop_sharing_data      = Setting.first.stop_sharing_this_month(date_time)
      current_sharing_data   = Setting.first.current_sharing_with_research_module

      shared_data << mapping_learning_module_date(setting, start_sharing_data)
      stop_sharing_date << mapping_learning_module_date(setting, stop_sharing_data)
      all_learning_data << mapping_learning_module_date(setting, current_sharing_data)

      ngo_worksheet.insert_row(index += 1, ngo_values)
      user_worksheet.insert_row(index, user_values)
      client_worksheet.insert_row(index, client_values)
      # learning_worksheet.insert_row(index + 2, learning_data.flatten)

      ngo_length_of_column.times do |i|
        ngo_worksheet.row(index).set_format(i, column_date_format) if i == 1
        next if i == 1
        ngo_worksheet.row(index).set_format(i, column_format)
      end

      user_length_of_column.times do |i|
        user_worksheet.row(index).set_format(i, column_format)
      end

      client_length_of_column.times do |i|
        client_worksheet.row(index).set_format(i, column_format)
      end

      (0..(sub_learning_columns.size - 1)).each do |i|
        learning_worksheet.row(index + 3).set_format(i, column_format)
      end
    end
    Organization.switch_to 'public'

    user_data = User.where.not(organization_name: nil).map do |user|
      [user.name, user.organization_name, user.sign_in_count]
    end

    book.write("tmp/OSCaR-usage-report-#{date_time}.xls")
    generate(date_time, previous_month)
  end


  private

  def generate(date_time, previous_month)
    NgoUsageReportWorker.perform_async(date_time, previous_month)
  end

  def mapping_learning_module_date(setting, data)
    [setting[:ngo_short_name].upcase, data.last['updated_at']&.last&.strftime("%d-%m-%Y")] if data.present?
  end
end
