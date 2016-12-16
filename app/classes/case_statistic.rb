class CaseStatistic

  CLIENT_ACTIVE_STATUS = ['Active EC', 'Active FC', 'Active KC'].freeze

  def initialize(clients)
    @clients = clients.where(status: CLIENT_ACTIVE_STATUS)
    @clients.first.cases.current
    @cases = Case.active.most_recents.where(client: @clients)
  end

  def statistic_data
    case_by_start_date = cases_grouped_by_case_type.group_by { |c| c.start_date.end_of_month.strftime "%b-%y"}.keys
    cases_by_case_type = cases_grouped_by_case_type.group_by(&:case_type).sort
    statistic_data, data_series = [], []
    statistic_data << case_by_start_date

    cases_by_case_type.each do |case_type, case_obj|
      data = {}
      cases_by_date = case_obj.group_by { |c| c.start_date.end_of_month.strftime "%b-%y" }

      series, client_count = [], []
      client_count << case_type_count(case_type)

      case_by_start_date.each do |date|
        if cases_by_date[date].present?
          client_count << cases_by_date[date].count
          series << client_count.sum
        else
          series << nil
        end
      end

      data[:name] = "Active #{case_type}"
      data[:data] = series
      data_series << data
    end
    statistic_data << data_series
    statistic_data
  end

  private

  def cases_grouped_by_case_type
    @cases.where(start_date: 12.months.ago..Date.today).order('start_date')
  end

  # def case_ids_by_client_status
  #
  # end

  def case_type_count(case_type)
    @cases.where('case_type = ? AND start_date < ?', case_type, 12.months.ago).size
  end
end
