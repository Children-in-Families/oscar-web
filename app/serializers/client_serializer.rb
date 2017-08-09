class ClientSerializer < ActiveModel::Serializer

  attributes  :id, :given_name, :family_name, :gender, :code, :status, :date_of_birth, :grade,
              :current_province, :local_given_name, :local_family_name, :kid_id, :donor,
              :current_address, :house_number, :street_number, :village, :commune, :district,
              :completed, :birth_province, :time_in_care, :initial_referral_date, :referral_source,
              :referral_phone, :live_with, :id_poor, :received_by,
              :followed_up_by, :follow_up_date, :school_name, :school_grade, :has_been_in_orphanage,
              :able_state, :has_been_in_government_care, :relevant_referral_information,
              :case_workers, :agencies, :state, :rejected_note, :emergency_care, :foster_care, :kinship_care,
              :organization, :additional_form, :tasks, :assessments, :case_notes, :quantitative_cases,
              :program_streams, :add_forms

  def case_workers
    object.users
  end

  def rejected_note
    object.rejected_note if object.status == "rejected"
  end

  def current_province
    object.province
  end

  def emergency_care
    CaseSerializer.new(object.cases.active.latest_emergency).serializable_hash
  end

  def organization
    object.organization
  end

  def additional_form
    custom_fields = object.custom_fields.uniq.sort_by(&:form_title)
    custom_fields.map do |custom_field|
      custom_field.as_json.merge(custom_field_properties: custom_field.custom_field_properties.where(custom_formable_id: object.id).as_json)
    end
  end

  def tasks
    overdue_tasks   = ActiveModel::ArraySerializer.new(object.tasks.overdue_incomplete, each_serializer: TaskSerializer)
    today_tasks     = ActiveModel::ArraySerializer.new(object.tasks.today_incomplete, each_serializer: TaskSerializer)
    upcoming_tasks  = ActiveModel::ArraySerializer.new(object.tasks.incomplete.upcoming, each_serializer: TaskSerializer)
    { overdue: overdue_tasks, today: today_tasks, upcoming: upcoming_tasks }
  end

  def case_notes
    object.case_notes.most_recents
  end

  def foster_care
    CaseSerializer.new(object.cases.active.latest_foster).serializable_hash
  end

  def kinship_care
    CaseSerializer.new(object.cases.active.latest_kinship).serializable_hash
  end

  def assessments
    object.assessments.map do |assessment|
      formatted_assessment_domain = assessment.assessment_domains_in_order.map do |ad|
        incomplete_tasks = object.tasks.by_domain_id(ad.domain_id).incomplete
        ad.as_json.merge(domain: ad.domain.as_json(only: [:name, :identity]), incomplete_tasks: incomplete_tasks.as_json(only: [:name, :id]))
      end
      assessment.as_json.merge(assessment_domain: formatted_assessment_domain)
    end
  end

  def case_notes
    object.case_notes.most_recents.map do |case_note|
      formatted_case_note_domain_group = case_note.case_note_domain_groups.map do |cdg|
        domain_scores = cdg.domain_group.domains.map do |domain|
          ad = domain.assessment_domains.find_by(assessment_id: case_note.assessment_id)
          ad.try(:score)
          { domain_id: ad.domain_id, score: ad.score } if ad.present?
        end.compact
        cdg.as_json.merge(domain_group_identities: cdg.domain_group.domain_identities, domain_scores: domain_scores, completed_tasks: cdg.completed_tasks)
      end
      case_note.as_json.merge(case_note_domain_group: formatted_case_note_domain_group)
    end
  end

  def quantitative_cases
    object.quantitative_cases.group_by(&:quantitative_type).map do |qtypes|
      qtype = qtypes.first.name
      qcases = qtypes.last.map{ |qcase| qcase.value }
      { quantitative_type: qtype, client_quantitative_cases: qcases }
    end
  end

  def program_streams
    object.program_streams.map do |program_stream|
      formatted_enrollments = program_stream.client_enrollments.map do |enrollment|
        trackings = enrollment.client_enrollment_trackings
        leave_program = enrollment.leave_program
        enrollment.as_json.merge( trackings: trackings, leave_program: leave_program )
      end
      domains = program_stream.domains.map(&:identity)
      program_stream.as_json(only: [:id, :name, :description, :quantity]).merge(domain: domains, enrollments: formatted_enrollments)
    end
  end

  def add_forms
    custom_field_ids = object.custom_field_properties.pluck(:custom_field_id)
    CustomField.client_forms.not_used_forms(custom_field_ids).order_by_form_title
  end

end
