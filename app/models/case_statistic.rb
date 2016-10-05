class CaseStatistic
  CLIENT_ACTIVE_STATUS = ['Active EC', 'Active FC', 'Active KC']

  def initialize(clients)
    @clients = clients
  end

  def statistic_data
    cases_by_case_type = cases_grouped_by_case_type
    statistic_data     = []

    cases_by_case_type.each do |case_type, case_obj|

      data = {}
      cases_by_date = case_obj.group_by { |c| c.start_date.end_of_month }
      data_by_date = {}
      client_count = []
      client_count << case_type_count(case_type)

      cases_by_date.each do |date, case_obj|
        client_count << case_obj.count
        data_by_date[date] = client_count.sum
      end

      data[:name] = "Active #{case_type}"
      data[:data] = data_by_date
      statistic_data << data
    end
    statistic_data
  end

  private
  def case_type_count(case_type)
    case_ids = case_ids_by_client_status
    Case.where(id: case_ids).where('case_type = ? AND start_date < ?', case_type, 12.months.ago).count
  end

  def cases_grouped_by_case_type
    case_ids = case_ids_by_client_status
    Case.where(id: case_ids).where(start_date: 12.months.ago..Date.today).order('start_date').group_by(&:case_type).sort
  end

  def case_ids_by_client_status
    case_ids = []
    client_ids = @clients.joins(:cases).where(cases: { exited: false }).pluck(:id).uniq
    client_ids.each do |client_id|
      client = Client.find(client_id)
      case_ids << client.cases.current.id if client.cases.current && CLIENT_ACTIVE_STATUS.include?(client.status)
    end
    case_ids
  end
end
