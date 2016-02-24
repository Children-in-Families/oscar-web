class ClientSerializer < ActiveModel::Serializer
  attributes  :id, :first_name, :last_name, :type, :date_of_birth,
              :gender, :current_address, :status, :school_grade,
              :care_details, :referral_date, :referral_follow_up_date,
              :emergency_care_case, :kinship_or_foster_care_case,
              :case_worker_id, :next_appointment_date, :case_worker,
              :most_recent_case_note, :birth_location, :carer_detail,
              :case_notes, :next_case_note_due_date, :followed_up_by, :referral_reasons

  def type
    'client'
  end

  def followed_up_by
    return unless object.followed_up_by.present?

    object.followed_up_by.name
  end

  def case_notes
    ActiveModel::ArraySerializer.new(object.kinship_or_foster_care_case.case_notes.order(id: :asc), each_serializer: CaseNoteSerializer).as_json
  end

  def next_case_note_due_date
    kc_fc = object.kinship_or_foster_care_case
    return unless kc_fc

    CaseNote.next_case_note_date_by_kc_fc_case(kc_fc)
  end

  def emergency_care_case
    object.emergency_care_case
  end

  def kinship_or_foster_care_case
    KinshipOrFosterCareCaseSerializer.new(object.kinship_or_foster_care_case).serializable_hash
  end

  def next_appointment_date
    return unless object.kinship_or_foster_care_case.present?

    object.kinship_or_foster_care_case.next_appointment_date
  end

  def case_worker
    object.try(:referral_recieved_by).try(:name)
  end

  def most_recent_case_note
    return unless object.kinship_or_foster_care_case.case_notes.blank?

    object.kinship_or_foster_care_case.case_notes.last.date
  end

  def birth_location
    object.birth_village.name if object.birth_village
  end

  def carer_detail
    return unless object.kinship_or_foster_care_case.try(:family)

    family = object.kinship_or_foster_care_case.family
    FamilySerializer.new(family).serializable_hash
  end
end
