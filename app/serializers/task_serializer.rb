class TaskSerializer < ActiveModel::Serializer
  attributes :id, :name, :expected_date, :completion_date, :domain, :completed, :user_id, :taskable_id, :taskable_type

  def domain
    object.domain.as_json(only: [:id, :name, :identity])
  end
end
