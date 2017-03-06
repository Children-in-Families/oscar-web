class ClientSerializer < ActiveModel::Serializer
  attributes :id, :code, :first_name, :last_name, :gender, :date_of_birth, :status,
             :initial_referral_date, :referral_phone, :follow_up_date, :current_address,
             :able, :reason_for_referral, :background, :user, :birth_province, :received_by,
             :followed_up_by, :referral_source, :cases, :name, :assessments, :most_recent_case_note, :next_appointment_date, :tasks,
             :organization
z
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
end
