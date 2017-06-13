class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :roles, :mobile, :date_of_birth, :archived, :admin, :manager_id, :pin_number, :overdue_tasks, :today_tasks, :upcoming_tasks

  def overdue_tasks
    overdue_tasks = Task.incomplete.of_user(object).overdue.group_by{ |task| task.client }
    overdue_tasks.map do |client, tasks|
      serialized_tasks = ActiveModel::ArraySerializer.new(tasks, each_serializer: TaskSerializer)
      { client: client.as_json(only: [:id, :given_name, :family_name, :local_given_name, :local_family_name]), tasks: serialized_tasks }
    end
  end

  def today_tasks
    today_tasks = Task.incomplete.of_user(object).today.group_by{ |task| task.client }
    today_tasks.map do |client, tasks|
      serialized_tasks = ActiveModel::ArraySerializer.new(tasks, each_serializer: TaskSerializer)
      { client: client.as_json(only: [:id, :given_name, :family_name, :local_given_name, :local_family_name]), tasks: serialized_tasks }
    end
  end

  def upcoming_tasks
    upcoming_tasks = Task.incomplete.of_user(object).upcoming.group_by{ |task| task.client }
    upcoming_tasks.map do |client, tasks|
      serialized_tasks = ActiveModel::ArraySerializer.new(tasks, each_serializer: TaskSerializer)
      { client: client.as_json(only: [:id, :given_name, :family_name, :local_given_name, :local_family_name]), tasks: serialized_tasks }
    end
  end
end