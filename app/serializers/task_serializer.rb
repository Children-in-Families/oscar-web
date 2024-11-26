class TaskSerializer < ActiveModel::Serializer
  attributes :id, :name, :expected_date, :completion_date, :domain, :completed, :user_id, :completed_by_id,
             :taskable_id, :taskable_type, :goal_id, :case_note_id, :case_note_domain_group_id, :relation

  def domain
    object.domain.as_json(only: [:id, :name, :identity])
  end
end
