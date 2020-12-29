module CreateNestedValue
  def create_nested_value(goal_in_params)
    assessment_id = goal_in_params.last[:assessment_id]
    assessment_domain_id = goal_in_params.last[:assessment_domain_id]
    description = goal_in_params.last[:description]

    goal_attr = Goal.new(assessment_domain_id: assessment_domain_id, assessment_id: assessment_id, description: description).attributes
    goal = @care_plan.goals.create(goal_attr)

    goal_in_params.last[:tasks_attributes].each do |task|
      domain_id = task.last[:domain_id]
      name = task.last[:name]
      completion_date =  task.last[:completion_date]
      relation =  task.last[:relation]
      goal_id = goal.id
      task_attr = Task.new(domain_id: domain_id, name: name, completion_date: completion_date, relation: relation, goal_id: goal_id).attributes
      goal.tasks.create(task_attr)
    end
  end
end
