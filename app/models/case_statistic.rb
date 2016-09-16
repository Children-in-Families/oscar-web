class CaseStatistic
  CLIENT_ACTIVE_STATUS = ['Active EC', 'Active FC', 'Active KC']

  def self.statistic_data
    cases_by_case_type = cases_grouped_by_case_type
    statistic_data     = []
    cases_by_case_type.each do |case_type, case_obj|
      data = {}
      cases_by_date = case_obj.group_by { |c| c.created_at.strftime('%B %Y') }
      data_by_date = {}
      client_count = []
      cases_by_date.each do |date, case_obj|
        client_count.push case_obj.count
        data_by_date[date] = client_count.sum
      end
      data[:name] = "Active #{case_type}"
      data[:data] = data_by_date
      statistic_data.push data
    end
    statistic_data
  end

  private
  def self.cases_grouped_by_case_type
    case_ids = case_ids_by_client_status
    Case.where(id: case_ids).order('created_at').group_by(&:case_type).sort
  end

  def self.case_ids_by_client_status
    case_ids = []
    Client.joins(:cases).where(cases: { exited: false }).uniq.each do |client|
      case_ids << client.cases.current.id if client.cases.current && CLIENT_ACTIVE_STATUS.include?(client.status)
    end
    case_ids
  end
end
