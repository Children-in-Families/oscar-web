class CaseStatistic
  CLIENT_ACTIVE_STATUS = ['Active EC', 'Active FC', 'Active KC']

  def initialize(start_date, end_date)
    @start_date = start_date
    @end_date = end_date
  end

  def statistic_data
    cases_by_case_type = cases_grouped_by_case_type
    statistic_data     = []
    cases_by_case_type.each do |case_type, case_obj|
      data = {}
      cases_by_date = case_obj.group_by { |c| c.start_date.strftime "%B %Y" }
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
  def cases_grouped_by_case_type
    case_ids = case_ids_by_client_status
    if @start_date.blank? || @end_date.blank?
      Case.where(id: case_ids).where(start_date: 12.months.ago..Date.today).order('start_date').group_by(&:case_type).sort
    else
      Case.where(id: case_ids).where(start_date: @start_date..@end_date).order('start_date').group_by(&:case_type).sort
    end
  end

  def case_ids_by_client_status
    case_ids = []
    Client.joins(:cases).where(cases: { exited: false }).uniq.each do |client|
      case_ids << client.cases.current.id if client.cases.current && CLIENT_ACTIVE_STATUS.include?(client.status)
    end
    case_ids
  end
end
