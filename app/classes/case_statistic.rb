class CaseStatistic
  def initialize(clients)
    @clients = clients.all_active_types
    @cases = Case.cases_by_clients(@clients)
  end

  def statistic_data
    case_start_dates   = one_year_cases.map(&:short_start_date).uniq
    cases_by_case_type = one_year_cases.group_by(&:case_type).sort
    statistic_data     = []
    data_series        = []

    statistic_data << case_start_dates

    cases_by_case_type.each do |case_type, case_obj|
      data = {}
      cases_by_date = case_obj.group_by(&:short_start_date)

      series = []
      client_cases_count_list = []
      client_cases_count_list << cases_count_by(case_type: case_type)

      case_start_dates.each do |date|
        if cases_by_date[date].present?
          client_cases_count_list << cases_by_date[date].count
          series << client_cases_count_list.sum
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

  def one_year_cases
    @cases.where(start_date: 12.months.ago..Date.today).order('start_date')
  end

  def cases_count_by(fields = {})
    @cases.where('case_type = ? AND start_date < ?', fields[:case_type], 12.months.ago).to_a.size
  end
end
