class StaffMonthlyReport
  protected

  def self.average_number_of_daily_login(user)
    total_login_per_month = user.visits.where(created_at: 1.month.ago.beginning_of_month..1.month.ago.end_of_month).count
    return 0 if total_login_per_month == 0
    total_day_of_month    = 1.month.ago.end_of_month.day
    average = (total_login_per_month.to_f / total_day_of_month.to_f).ceil
  end

  def self.average_casenote_characters(user)
    user_client_ids = user.clients.ids
    return 0 if user_client_ids.empty?
    last_month_casenotes = CaseNote.where(created_at: 1.month.ago.beginning_of_month..1.month.ago.end_of_month)
    total_casenotes = last_month_casenotes.joins(:client).where(clients: { id: user_client_ids }).count
    return 0 if total_casenotes == 0
    total_casenote_chars = last_month_casenotes.joins(:client).where(clients: { id: user_client_ids }).joins(:case_note_domain_groups).where.not(case_note_domain_groups: { note: '' }).pluck(:note).join('').length
    average = (total_casenote_chars.to_f / total_casenotes.to_f).ceil
  end

  def self.average_number_of_casenotes_completed_per_client(user)
    user_client_ids = user.clients.ids
    return 0 if user_client_ids.empty?
    total_clients = user.clients.count
    last_month_casenotes = CaseNote.where(created_at: 1.month.ago.beginning_of_month..1.month.ago.end_of_month)
    total_casenotes = last_month_casenotes.joins(:client).where(clients: { id: user_client_ids }).count
    average = (total_casenotes.to_f / total_clients.to_f).ceil
  end

  def self.average_length_of_time_completing_csi_for_each_client(user)
    user_client_ids = user.clients.ids
    return 0 if user_client_ids.empty?
    last_month_assessments = Assessment.where(client_id: user_client_ids, created_at: 1.month.ago.beginning_of_month..1.month.ago.end_of_month)
    return 0 if last_month_assessments.empty?
    client_with_two_assessments = 0
    duration = 0
    last_month_assessments.group_by(&:client_id).each do |client_id, assessments|
      last_two_assessments = Client.find(client_id).assessments.order(:created_at).last(2)
      return 0 if last_two_assessments.size < 2
      client_with_two_assessments += 1
      duration += Client.find(client_id).assessments.order(:created_at).last(2).inject{ |a, b| (b.created_at.year * 12 + b.created_at.month) - (a.created_at.year * 12 + a.created_at.month) }
    end
    average = (duration.to_f  / client_with_two_assessments.to_f).ceil
  end
end
