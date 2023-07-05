class ClientListingSerializer < ActiveModel::Serializer
  attributes :id, :name, :gender, :status, :profile, :date_of_birth, :current_family_id,
             :assessments_count, :case_notes_count, :tasks_count, :risk_assessment_status, :updated_at

  def profile
    object.profile.present? ? { uri: object.profile.url } : {}
  end

  def case_notes_count
    object.case_notes.count
  end

  def tasks_count
    object.tasks.incomplete.count
<<<<<<< HEAD
  end

  def risk_assessment_status
    object.assessments.last&.level_of_risk || object.risk_assessment&.level_of_risk
=======
>>>>>>> 44f47638b (Fixed client_listing_serializer count only incompleted tasks)
  end
end
