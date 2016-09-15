class CaseStatistic
  def self.statistic_data
    c_ids = []
    client_status = ['Active EC', 'Active FC', 'Active KC']
    Client.joins(:cases).where(cases: { exited: false}).uniq.each do |c|
      c_ids << c.cases.current.id if c.cases.current && client_status.include?(c.status)
    end

    data = []
    cases = Case.where(id: c_ids).order('created_at').group_by(&:case_type)
    cases.each do |k, v|
      h = {}
      case_group_date = v.group_by { |c| c.created_at.strftime('%B %Y') }
      data_by_date = {}
      value = []
      case_group_date.each do |k, v|
        value.push v.count
        data_by_date[k] = value.sum
      end
      h[:name] = "Active #{k}"
      h[:data] = data_by_date
      data.push h
    end
    return data
  end
end