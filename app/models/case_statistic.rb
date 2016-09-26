class CaseStatistic
  CLIENT_ACTIVE_STATUS = ['Active EC', 'Active FC', 'Active KC']

  def initialize(clients)
    @clients = clients
  end

  def statistic_data
    cases_by_case_type = cases_grouped_by_case_type[1]
    statistic_data     = []

    cases_by_case_type.each do |case_type, case_obj|

      data = {}
      cases_by_date = case_obj.group_by { |c| c.start_date.strftime "%B %Y" }
      data_by_date = {}
      client_count = []

      if cases_grouped_by_case_type[0].present?
        if case_type == 'EC'
          client_count << cases_grouped_by_case_type[0].first[1].count
        elsif case_type == 'FC'
          client_count << cases_grouped_by_case_type[0].second[1].count
        elsif case_type == 'KC'
          client_count <<  cases_grouped_by_case_type[0].last[1].count
        end
      else
        client_count << 0
      end

      cases_by_date.each do |date, case_obj, i = 1|
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
    case_count = []

    if @start_date.blank? || @end_date.blank?
      data_before_start_date = Case.where(id: case_ids).where('start_date < ?', 12.months.ago).
                                order('start_date').group_by(&:case_type).sort
      data_filter = Case.where(id: case_ids).where(start_date: 12.months.ago..Date.today).
                      order('start_date').group_by(&:case_type).sort

      case_count << data_before_start_date
      case_count << data_filter
    else
      data_before_start_date = Case.where(id: case_ids).where('start_date < ?', @start_date).
                                order('start_date').group_by(&:case_type).sort
      data_filter = Case.where(id: case_ids).where(start_date: @start_date..@end_date).
                        order('start_date').group_by(&:case_type).sort

      case_count << data_before_start_date
      case_count << data_filter
    end
  end

  def case_ids_by_client_status
    case_ids = []
    @clients.joins(:cases).where(cases: { exited: false }).uniq.each do |client|
      case_ids << client.cases.current.id if client.cases.current && CLIENT_ACTIVE_STATUS.include?(client.status)
    end
    case_ids
  end
end
