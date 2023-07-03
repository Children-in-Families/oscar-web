class ClientListingSerializer < ActiveModel::Serializer
  attributes  :id, :name, :assessments_count, :case_note_count, :task_count

  def case_notes_count
    object.case_notes.count
  end

  def tasks_count
    object.tasks.count
  end
end
