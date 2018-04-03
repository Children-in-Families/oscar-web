class StaffMonthlyReport
  protected

  def self.times_visiting_clients_profile(user)
    total_visit_per_month = user.visit_clients.where(created_at: 1.month.ago.beginning_of_month..1.month.ago.end_of_month).count
  end

  def self.average_casenote_characters(user)
    user_client_ids = user.clients.ids
    return 0 if user_client_ids.empty?
    last_month_casenotes = CaseNote.where(created_at: 1.month.ago.beginning_of_month..1.month.ago.end_of_month)
    total_casenotes = last_month_casenotes.joins(:client).where(clients: { id: user_client_ids }).count
    return 0 if total_casenotes == 0
    total_casenote_chars = last_month_casenotes.joins(:client).where(clients: { id: user_client_ids }).joins(:case_note_domain_groups).where.not(case_note_domain_groups: { note: '' }).pluck(:note).join('').length
    average = (total_casenote_chars.to_f / total_casenotes.to_f).round(2)
  end

  def self.average_number_of_casenotes_completed_per_client(user)
    user_client_ids = user.clients.ids
    return 0 if user_client_ids.empty?
    total_clients = user.clients.count
    last_month_casenotes = CaseNote.where(created_at: 1.month.ago.beginning_of_month..1.month.ago.end_of_month)
    total_casenotes = last_month_casenotes.joins(:client).where(clients: { id: user_client_ids }).count
    average = (total_casenotes.to_f / total_clients.to_f).round(2)
  end

  def self.average_length_of_time_completing_csi_for_each_client(user)
    user_client_ids = user.clients.ids
    return 0 if user_client_ids.empty?
    last_month_assessments = Assessment.where(client_id: user_client_ids, created_at: 1.month.ago.beginning_of_month..1.month.ago.end_of_month)
    return 0 if last_month_assessments.empty?
    client_with_two_assessments = 0
    duration_as_days = 0
    last_month_assessments.group_by(&:client_id).each do |client_id, assessments|
      last_two_assessments = Client.find(client_id).assessments.order(:created_at).last(2)
      return 0 if last_two_assessments.size < 2
      client_with_two_assessments += 1
      duration_as_days += Client.find(client_id).assessments.order(:created_at).last(2).inject{ |a, b| (b.created_at.to_date - a.created_at.to_date).to_i }
    end
    average = (duration_as_days.to_f  / client_with_two_assessments.to_f).round(2)
  end

  def self.average_number_of_duetoday_tasks_each_day(user)
    total_day_of_month    = 1.month.ago.end_of_month.day
    due_today_tasks_count = 0
    start_date = 1.month.ago.beginning_of_month.to_date
    end_date = 1.month.ago.end_of_month.to_date
    (start_date..end_date).each do |date|
      incomplete_today_task_histories_count = TaskHistory.where({ '$and' => [{'object.completion_date' => date}, {'object.completed' => false}, {'object.user_id': user.id}] }).group_by{|t| t.object['id'] }.size
      due_today_tasks_count += incomplete_today_task_histories_count
    end
    return 0 if due_today_tasks_count == 0
    average = (due_today_tasks_count.to_f / total_day_of_month.to_f).round(2)
  end

  def self.average_number_of_overdue_tasks_each_day(user)
    total_day_of_month    = 1.month.ago.end_of_month.day
    overdue_tasks_count = 0
    start_date = 1.month.ago.beginning_of_month.to_date
    end_date = 1.month.ago.end_of_month.to_date
    (start_date..end_date).each do |date|
      incomplete_overdue_task_histories_count = TaskHistory.lte('object.completion_date' => date).where({ '$and' => [{'object.completed' => false}, {'object.user_id': user.id}] }).group_by{|t| t.object['id'] }.size
      overdue_tasks_count = incomplete_overdue_task_histories_count
    end
    return 0 if overdue_tasks_count == 0
    average = (overdue_tasks_count.to_f / total_day_of_month.to_f).round(2)
  end
end
