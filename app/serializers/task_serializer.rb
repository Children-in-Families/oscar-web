class TaskSerializer < ActiveModel::Serializer
  attributes :id, :name, :completion_date, :remind_at, :case_note_domain_group_id, :domain_id, :completed
end
