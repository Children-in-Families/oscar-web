class KinshipOrFosterCareCaseSerializer < ActiveModel::Serializer
  attributes :id, :type

  #def tasks
    #object.tasks.where(finished_date: nil).order(order: :asc)
  #end
end
