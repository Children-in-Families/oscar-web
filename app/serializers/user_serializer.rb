class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :roles, :mobile, :date_of_birth, :archived, :admin, :manager_id, :pin_number, :clients

  def clients
    object.clients.map do |client|
      incompleted_tasks = client.tasks.incomplete
      next unless incompleted_tasks.present?
      formatted_client = client.as_json(only: [:id, :given_name, :family_name, :local_given_name, :local_family_name])
      formatted_client.merge(overdue: incompleted_tasks.overdue, today: incompleted_tasks.today, upcoming: incompleted_tasks.upcoming)
    end.compact
  end
end