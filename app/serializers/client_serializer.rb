class ClientSerializer < ActiveModel::Serializer
  attributes  :id, :code, :given_name, :family_name, :local_given_name, :local_family_name, :gender,
              :date_of_birth, :kid_id, :donor_name, :status, :current_province, :current_address,
              :house_number, :street_number, :village, :commune, :district, :completed, :time_in_care,
              :initial_referral_date, :referral_phone, :referral_source,:follow_up_date, :followed_up_by,
              :able, :reason_for_referral, :background, :able_state, :rejected_note, :user, :birth_province,
              :received_by, :school_name, :school_grade, :has_been_in_orphanage, :state, :agencies_involved,
              :has_been_in_government_care, :relevant_referral_information, :cases, :name, :assessments,
              :most_recent_case_note, :next_appointment_date, :tasks, :organization

  def tasks
    ActiveModel::ArraySerializer.new(object.tasks.incomplete, each_serializer: TaskSerializer)
  end

  def name
    object.name.strip
  end

  def assessments
    ActiveModel::ArraySerializer.new(object.assessments, each_serializer: AssessmentSerializer)
  end

  def cases
    ActiveModel::ArraySerializer.new(object.cases, each_serializer: CaseSerializer)
  end

  def user
    object.user.as_json(only: [:first_name, :last_name, :email], methods: [:name])
  end

  def birth_province
    object.province if object.province
  end

  def received_by
    object.received_by.as_json(only: [:first_name, :last_name, :email], methods: [:name]) if object.received_by
  end

  def followed_up_by
    object.followed_up_by.as_json(only: [:first_name, :last_name, :email], methods: [:name]) if object.followed_up_by
  end

  def referral_source
    object.referral_source if object.referral_source
  end

  def most_recent_case_note
    object.case_notes.most_recents.first.meeting_date.try(:to_date) if object.case_notes.any?
  end

  def next_appointment_date
    object.next_appointment_date.to_date
  end

  def current_province
    object.province.name if object.province
  end

  def rejected_note
    object.rejected_note if object.state == "rejected"
  end

  def birth_province
    object.birth_province.name if object.birth_province
  end

  def received_by
    object.received_by.name if object.received_by
  end

  def agencies_involved
    object.agencies.map(&:name) if object.agencies
  end
end
