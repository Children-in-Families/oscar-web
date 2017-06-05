class ClientSerializer < ActiveModel::Serializer

  attributes  :id, :given_name, :family_name, :gender, :code, :status, :date_of_birth, :grade,
              :current_province, :local_given_name, :local_family_name, :kid_id, :donor_name,
              :current_address, :house_number, :street_number, :village, :commune, :district,
              :completed, :birth_province, :time_in_care, :initial_referral_date, :referral_source,
              :referral_phone, :who_live_with, :poverty_certificate, :rice_support, :received_by,
              :followed_up_by, :follow_up_date, :school_name, :school_grade, :has_been_in_orphanage,
              :able_state, :has_been_in_government_care, :relevant_referral_information,
              :case_worker, :agencies, :state, :rejected_note, :emergency_care, :foster_care, :kinship_care,
              :organization, :additional_form, :tasks, :assessments, :case_notes

  def case_worker
    object.user
  end

  def rejected_note
    object.rejected_note if status == "rejected"
  end

  def current_province
    object.province
  end

  def who_live_with
    object.live_with
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
    ActiveModel::ArraySerializer.new(object.tasks.incomplete, each_serializer: TaskSerializer)
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
      formatted_assessment_domain = assessment.assessment_domains.map do |ad|
        ad.as_json.merge(domain: ad.domain.as_json(only: [:name, :identity]))
      end
      assessment.as_json.merge(assessment_domain: formatted_assessment_domain)
    end
  end

  def case_notes
    object.case_notes.most_recents.map do |case_note|
      formatted_case_note_domain_group = case_note.case_note_domain_groups.map do |cdg|
        domain_scores = cdg.domain_group.domains.map do |domain|
          ad = domain.assessment_domains.find_by(assessment_id: case_note.assessment_id)
          ad.score
        end
        cdg.as_json.merge(domain_group_identities: cdg.domain_group.domain_identities, domain_scores: domain_scores, completed_tasks: cdg.completed_tasks)
      end
      case_note.as_json.merge(case_note_domain_group: formatted_case_note_domain_group)
    end
  end
end