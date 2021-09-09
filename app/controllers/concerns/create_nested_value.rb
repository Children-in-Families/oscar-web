module CreateNestedValue
  include GoogleCalendarServiceConcern

  def create_nested_value(goal_in_params)
    assessment_id = goal_in_params.last[:assessment_id]
    assessment_domain_id = goal_in_params.last[:assessment_domain_id]
    description = goal_in_params.last[:description]
    return if description == ''

    goal_attr = Goal.new(assessment_domain_id: assessment_domain_id, assessment_id: assessment_id, description: description).attributes
    goal = @care_plan.goals.create(goal_attr)

    if goal_in_params.last[:tasks_attributes].present?
      goal_in_params.last[:tasks_attributes].each do |task|
        previous_id = task.last[:id]
        domain_id = task.last[:domain_id]
        name = task.last[:name]
        expected_date =  task.last[:expected_date]
        relation =  task.last[:relation]
        goal_id = goal.id
        task_attr = Task.new(domain_id: domain_id, name: name, previous_id: previous_id, expected_date: expected_date, relation: relation, goal_id: goal_id, client_id: @care_plan.client_id, user_id: current_user.id, family_id: @care_plan.family&.id).attributes
        goal.tasks.create(task_attr)
        create_goal_tasks(goal.tasks)
      end
    end
    set_care_plan_completed(@care_plan)
  end

  def update_nested_value(goal_in_params)
    assessment_id = goal_in_params.last[:assessment_id]
    assessment_domain_id = goal_in_params.last[:assessment_domain_id]
    description = goal_in_params.last[:description]

    return if description == ''

    goal_id = goal_in_params.last[:id]

    return if goal_id.nil? && description == ''

    if goal_id.nil?
      goal_attr = Goal.new(assessment_domain_id: assessment_domain_id, assessment_id: assessment_id, description: description).attributes
      goal = @care_plan.goals.create(goal_attr)

      goal_in_params.last[:tasks_attributes].each do |task|
        previous_id = task.last[:id]
        domain_id = task.last[:domain_id]
        name = task.last[:name]
        expected_date = task.last[:expected_date]
        relation = task.last[:relation]
        goal_id = goal.id
        task_attr = Task.new(domain_id: domain_id, previous_id: previous_id, name: name, expected_date: expected_date, relation: relation, goal_id: goal_id, client_id: @care_plan.client_id, user_id: current_user.id, family_id: @care_plan.family&.id).attributes
        goal.tasks.create(task_attr)
        create_goal_tasks(goal.tasks)
      end
    else
      goal = Goal.find_by(id: goal_id)
      if goal_in_params.last[:_destroy] == '1'
        goal.tasks.all.each(&:destroy_fully!)
        goal.reload.destroy
      elsif description == ''
        goal.tasks.each(&:destroy_fully!)
        goal.reload.destroy
      else
        update_goal_attributes(goal, goal_in_params)
      end
    end
    set_care_plan_completed(@care_plan)
  end

  def set_care_plan_completed(care_plan)
    required_assessment_domains = []

    care_plan.assessment.assessment_domains.each do |assessment_domain|
      required_assessment_domains << assessment_domain if assessment_domain[:score] == 1 || assessment_domain[:score] == 2
    end

    required_assessment_domains.each do |ad|
      if care_plan.goals.where(assessment_domain_id: ad.id).empty? || (care_plan.goals.where(assessment_domain_id: ad.id).present? && care_plan.goals.where(assessment_domain_id: ad.id).first.tasks.empty?)
        care_plan.update_attributes(completed: false)
        return true
      end
    end

    care_plan.update_attributes(completed: true)
  end

  def update_goal_attributes(goal, goal_in_params)
    goal.update_attributes(description: goal_in_params.last[:description])
    if goal_in_params.last[:tasks_attributes].present?
      goal_in_params.last[:tasks_attributes].each do |task|
        task_id = task.last[:id]
        if task_id.nil?
          domain_id = task.last[:domain_id]
          name = task.last[:name]
          expected_date = task.last[:expected_date]
          relation = task.last[:relation]
          goal_id = goal.id
          task_attr = Task.new(domain_id: domain_id, name: name, expected_date: expected_date, relation: relation, goal_id: goal_id, client_id: @care_plan.client_id, user_id: current_user.id, family_id: @care_plan.family&.id).attributes
          goal.tasks.create(task_attr)
          create_goal_tasks(goal.tasks)
        else
          existed_task = Task.find_by(id: task_id)
          if task.last[:_destroy] == '1'
            existed_task.destroy_fully!
          else
            existed_task.update_attributes(name: task.last[:name], expected_date: task.last[:expected_date], family_id: @care_plan.family&.id)
          end
        end
      end
    end
  end

  def create_goal_tasks(tasks)
    tasks.each do |task|
      next if task.expected_date.nil?
      Calendar.populate_tasks(task)
    end
    create_events if session[:authorization]
  end

end
