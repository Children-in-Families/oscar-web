class TaskSerializer < ActiveModel::Serializer
  attributes :id, :domain, :name, :finished_date, :order
end
