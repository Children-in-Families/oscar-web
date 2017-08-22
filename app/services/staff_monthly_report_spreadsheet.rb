class StaffMonthlyReportSpreadsheet
  def initialize
  end

  def usage_report(date_time)
    import_user_monthly_report(date_time)
  end

  private

  def import_user_monthly_report(date_time)
    column_names   = ['Staff Name', 'Permission Set', 'Average number of dalily logins', 'Average character count of case notes', 'Average number of case notes completed per client', 'Average number of due today tasks for each day', 'Average number of overdue tasks for each day', 'Average length of time between completing CSI assessments for each client']
    book           = Spreadsheet::Workbook.new

    header_format = Spreadsheet::Format.new(
      horizontal_align: :center,
      vertical_align: :center,
      shrink: true,
      border: :thin,
      size: 11
    )

    previous_month     = 1.month.ago.strftime('%B %Y')
    Organization.order(:created_at).each_with_index do |org, index|
      Organization.switch_to org.short_name
      worksheet = book.create_worksheet(name: org.full_name)
      worksheet.insert_row(0, column_names)

      column_names.length.times do |i|
        worksheet.row(0).set_format(i, header_format)
      end

      worksheet.row(0).height = 20
      worksheet.column(0).width = 25
      worksheet.column(1).width = 35
      worksheet.column(2).width = 35
      worksheet.column(3).width = 45
      worksheet.column(4).width = 50
      worksheet.column(5).width = 45
      worksheet.column(6).width = 45
      worksheet.column(7).width = 70

      User.non_strategic_overviewers.order(:first_name, :last_name).each_with_index do |user, index|
        number_of_daily_login                         = StaffMonthlyReport.average_number_of_daily_login(user)
        casenote_characters                           = StaffMonthlyReport.average_casenote_characters(user)
        casenotes_completed_per_client                = StaffMonthlyReport.average_number_of_casenotes_completed_per_client(user)
        length_of_time_completing_csi_for_each_client = StaffMonthlyReport.average_length_of_time_completing_csi_for_each_client(user)
        values = [user.name, user.roles, number_of_daily_login, casenote_characters, casenotes_completed_per_client, 'Average number of due today tasks for each day', 'Average number of overdue tasks for each day', length_of_time_completing_csi_for_each_client]
        worksheet.insert_row(index += 1, values)
      end
    end

    book.write("tmp/staff-monthly-report-#{date_time}.xls")
    generate(date_time, previous_month)
  end

  def generate(date_time, previous_month)
    StaffMonthlyReportWorker.perform_async(date_time, previous_month)
  end
end
