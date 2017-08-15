class TaskSerializer < ActiveModel::Serializer
  attributes :id, :name, :completion_date, :domain, :completed, :user_id

  def domain
    object.domain.as_json(only: [:id, :name, :identity])
  end
end
