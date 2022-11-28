module TasksHelper
  def domains_tasks(case_note, case_note_domain_group)
    case_note.client.tasks.where(domain_id: case_note_domain_group.domain_group.domains.ids)
  end

  def task_status(task)
    if task.completion_date < Date.today
      t('.overdue_tasks')
    elsif task.completion_date == Date.today
      t('.today_tasks')
    else
      t('.upcoming_tasks')
    end
  end

  def task_class(task)
    if task.completion_date < Date.today
      'danger'
    elsif task.completion_date == Date.today
      'info'
    else
      'primary'
    end
  end

  def damain_task_translation(domain)
    if domain.custom_domain == true
      "#{domain.name} #{domain.identity}"
    else
      t("domains.domain_names.#{domain.name.downcase.reverse}") + " " + t("domains.domain_identies.#{domain.identity.strip.parameterize.underscore}_#{domain.name.downcase}")
    end
  end
end
