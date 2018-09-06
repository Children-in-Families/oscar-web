module GovernmentFormsHelper
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

  def form_partial(form_name)
    case form_name
    when 'ទម្រង់ទី១: ព័ត៌មានបឋម' then 'one'
    when 'ទម្រង់ទី២: ការប៉ាន់ប្រមាណករណី និងគញរួសារ' then 'two'
    when 'ទម្រង់ទី៣: ផែនការសេវាសំរាប់ករណី​ និង គ្រួសារ' then 'three'
    when 'ទម្រង់ទី៤: ការទុកដាក់កុមារ' then 'four'
    end
  end
end
