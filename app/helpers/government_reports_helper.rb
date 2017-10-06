module GovernmentReportsHelper
  def checked?(value)
    'checked' if @client.quantitative_cases.pluck(:value).any? { |e| e.include?(value) }
  end

  def need_rank(need)
    # Need.find_by(name: need).client_needs.find_by(client_id: @client.id).try(:rank)
    need = Need.find_by(name: need)
    return '' unless need.present?
    @client.client_needs.find_by(need_id: need.id).try(:rank)
  end

  def problem_rank(problem)
    # Problem.find_by(name: problem).client_problems.find_by(client_id: @client.id).try(:rank)
    problem = Problem.find_by(name: problem)
    return '' unless problem.present?
    @client.client_problems.find_by(problem_id: problem.id).try(:rank)
  end
end
