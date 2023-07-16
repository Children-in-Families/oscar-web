class ClientListingSerializer < ActiveModel::Serializer
  attributes :id, :name, :gender, :profile, :date_of_birth, :assessments_count, :case_notes_count, :tasks_count

  def profile
    object.profile.present? ? { uri: object.profile.url } : {}
  end

  def case_notes_count
    object.case_notes.count
  end

  def tasks_count
    object.tasks.count
  end
end
