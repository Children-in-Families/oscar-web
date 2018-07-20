module GovernmentFormsHelper
  def checked?(value)
    'checked' if @client.quantitative_cases.pluck(:value).any? { |e| e.include?(value) }
  end

  def need_rank(need)
    need = Need.find_by(name: need)
    return '' unless need.present?
    @government_form.government_form_needs.find_by(need_id: need.id).try(:rank)
  end

  def problem_rank(problem)
    problem = Problem.find_by(name: problem)
    return '' unless problem.present?
    @government_form.government_form_problems.find_by(problem_id: problem.id).try(:rank)
  end
end
