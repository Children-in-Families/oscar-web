class StaffMonthlyReportSpreadsheet
  def initialize
  end

  def usage_report(date_time)
    Organization.all.each do |org|
      import_user_monthly_report(date_time, org)
    end
  end

  private

  def import_user_monthly_report(date_time, org)
    column_names   = ['Staff Name', 'Permission Set', 'Total number of times client profiles have been accessed', 'Average character count of case notes', 'Average number of case notes completed per client', 'Average number of due today tasks for each day', 'Average number of overdue tasks for each day', 'Average length of time of completing CSI assessments for each client']
    previous_month = 1.month.ago.strftime('%B %Y')
    Organization.switch_to(org.short_name)
    create_case_worker_worksheet(column_names, date_time, previous_month, org.short_name)
    create_admin_worksheet(column_names, date_time, previous_month, org.short_name)
  end

  private

  def create_case_worker_worksheet(column_names, date_time, previous_month, org_short_name)
    User.non_devs.managers.staff_performances.each do |user|
      book = Spreadsheet::Workbook.new
      worksheet = book.create_worksheet(name: previous_month)

      set_format_header(worksheet, column_names)

      case_workers = User.non_devs.where('manager_ids && ARRAY[?] or manager_id = ?', user.id, user.id).order(:first_name, :last_name)
      next if case_workers.empty?

      case_workers.each_with_index do |case_worker, index|
        worksheet.insert_row(index += 1, value_of_worksheet(case_worker))
      end

      user_name = user.name.gsub(/\s+/, '')
      file_name = "#{user_name}-subordinates-performance-report-#{date_time}.xls"
      book.write("tmp/#{file_name}")
      generate(user.id, file_name, previous_month, org_short_name, user.name)
    end
  end

  def create_admin_worksheet(column_names, date_time, previous_month, org_short_name)
    book = Spreadsheet::Workbook.new
    worksheet = book.create_worksheet(name: previous_month)

    set_format_header(worksheet, column_names)

    case_worker_without_manager = User.non_devs.where(manager_id: nil).order(:first_name, :last_name)
    return if case_worker_without_manager.empty?
    case_worker_without_manager.each_with_index do |case_worker, index|
      worksheet.insert_row(index += 1, value_of_worksheet(case_worker))
    end

    user_ids = User.non_devs.admins.staff_performances.ids
    file_name = "subordinates-performance-report-#{date_time}.xls"
    book.write("tmp/#{file_name}")
    generate(user_ids, file_name, previous_month, org_short_name, 'Admins')
  end

  def set_format_header(worksheet, column_names)
    header_format = Spreadsheet::Format.new(
      horizontal_align: :center,
      vertical_align: :center,
      shrink: true,
      border: :thin,
      size: 11
    )
    worksheet.insert_row(0, column_names)
    column_names.length.times do |i|
      worksheet.row(0).set_format(i, header_format)
    end
    worksheet.row(0).height = 20
    worksheet.column(0).width = 25
    worksheet.column(1).width = 35
    worksheet.column(2).width = 60
    worksheet.column(3).width = 45
    worksheet.column(4).width = 50
    worksheet.column(5).width = 45
    worksheet.column(6).width = 45
    worksheet.column(7).width = 70
  end

  def value_of_worksheet(case_worker)
    number_of_daily_login                         = StaffMonthlyReport.times_visiting_clients_profile(case_worker)
    casenote_characters                           = sprintf("%.2f", StaffMonthlyReport.average_casenote_characters(case_worker))
    casenotes_completed_per_client                = sprintf("%.2f", StaffMonthlyReport.average_number_of_casenotes_completed_per_client(case_worker))
    length_of_time_completing_csi_for_each_client = sprintf("%.2f", StaffMonthlyReport.average_length_of_time_completing_csi_for_each_client(case_worker))
    duetoday_tasks_each_day                       = sprintf("%.2f", StaffMonthlyReport.average_number_of_duetoday_tasks_each_day(case_worker))
    overdue_tasks_each_day                        = sprintf("%.2f", StaffMonthlyReport.average_number_of_overdue_tasks_each_day(case_worker))
    
    [case_worker.name, case_worker.roles, number_of_daily_login, casenote_characters, casenotes_completed_per_client, duetoday_tasks_each_day, overdue_tasks_each_day, length_of_time_completing_csi_for_each_client]
  end

  def generate(user_ids, file_name, previous_month, org_short_name, receiver)
    StaffMonthlyReportWorker.perform_async(user_ids, file_name, previous_month, org_short_name, receiver)
  end
end
