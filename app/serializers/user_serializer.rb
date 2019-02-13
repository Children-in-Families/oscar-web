class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :roles, :mobile, :date_of_birth, :archived, :admin, :manager_id, :pin_code, :clients, :gender

  def clients
    object.clients.map do |client|
      incompleted_tasks = client.tasks.incomplete
      formatted_client  = client.as_json(only: [:id, :given_name, :family_name, :local_given_name, :local_family_name])
      overdue_tasks     = ActiveModel::ArraySerializer.new(incompleted_tasks.overdue, each_serializer: TaskSerializer)
      today_tasks       = ActiveModel::ArraySerializer.new(incompleted_tasks.today, each_serializer: TaskSerializer)
      upcoming_tasks    = ActiveModel::ArraySerializer.new(incompleted_tasks.upcoming, each_serializer: TaskSerializer)

      formatted_client.merge(overdue: overdue_tasks, today: today_tasks, upcoming: upcoming_tasks)
    end.compact
  end
end
