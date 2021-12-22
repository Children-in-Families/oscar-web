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
    when 'ទម្រង់ទី២: ការប៉ាន់ប្រមាណករណី និងគ្រួសារ' then 'two'
    when 'ទម្រង់ទី៣: ផែនការសេវាសំរាប់ករណី​ និង គ្រួសារ' then 'three'
    when 'ទម្រង់ទី៤: ការទុកដាក់កុមារ' then 'four'
    when 'ទម្រង់ទី៥: តាមដាន និងត្រួតពិនិត្យ' then 'five'
    when 'ទម្រង់ទី៦: ប៉ាន់ប្រមាណចុងក្រោយ' then 'six'
    end
  end

  def profile_photo(client_profile)
    if client_profile.present?
      wicked_pdf_image_tag @client.profile.photo, alt: @client.profile.file.filename, class: 'pull-right', width: 100
    else
      wicked_pdf_image_tag 'picture.png', id: 'client_photo', class: 'pull-right', width: 100
    end
  end

  def client_code_government_forms(client_code)
    return client_code&.last(4) if client_code&.length == 4
    client_code&.length <= 10 ? client_code.last(2) : client_code&.last(4)
  end
end
