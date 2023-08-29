class ClientSerializer < ActiveModel::Serializer
  attributes  :id, :given_name, :family_name, :gender, :code, :status, :date_of_birth, :grade,
              :current_province, :local_given_name, :local_family_name, :kid_id, :donors,
              :current_address, :house_number, :street_number, :village, :commune, :district, :profile,
              :completed, :birth_province, :time_in_cps, :initial_referral_date, :referral_source, :what3words, :name_of_referee,
              :referral_phone, :live_with, :received_by, :main_school_contact,  :telephone_number,
              :followed_up_by, :follow_up_date, :school_name, :school_grade,
              :relevant_referral_information, :rated_for_id_poor, :case_workers, :agencies, :state, :rejected_note,
              :organization, :additional_form, :tasks, :assessments, :case_notes, :quantitative_cases,
              :program_streams, :add_forms, :inactive_program_streams, :enter_ngos, :exit_ngos, :time_in_ngo, :referral_source_category_id,
              :outside, :outside_address, :address_type, :client_phone, :phone_owner, :client_email, :referee_relationship, :concern_is_outside,
              :concern_outside_address, :concern_province_id, :concern_district_id, :concern_commune_id, :concern_village_id, :concern_street,
              :concern_house, :concern_address, :concern_address_type, :concern_phone, :concern_phone_owner, :concern_email, :concern_email_owner,
              :concern_location, :concern_same_as_client, :location_description, :id_number, :other_phone_number, :brsc_branch, :current_island,
              :current_street, :current_po_box, :current_city, :current_settlement, :current_resident_own_or_rent, :current_household_type,
              :island2, :street2, :po_box2, :city2, :settlement2, :resident_own_or_rent2, :household_type2, :legacy_brcs_id, :whatsapp,
              :global_id, :external_id, :external_id_display, :mosvy_number, :external_case_worker_name, :external_case_worker_id,
              :other_phone_whatsapp, :preferred_language, :national_id, :birth_cert, :family_book, :passport, :referred_external,
              :marital_status, :nationality, :ethnicity, :location_of_concern, :type_of_trafficking, :education_background, :department, :locality,
              :ngo_partner, :quantitative_case_ids, :brc_client_address, :family, :updated_at

  has_one :carer
  has_one :referee
  has_one :risk_assessment

  has_many :assessments
  has_many :client_quantitative_free_text_cases

  def profile
    object.profile.present? ? { uri: object.profile.url } : {}
  end

  def time_in_ngo
    if object.time_in_ngo.present?
      years = object.time_in_ngo[:years]
      year_string = "#{years} #{'year'.pluralize(years)}" if years > 0
      months = object.time_in_ngo[:months]
      month_string = "#{months} #{'month'.pluralize(months)}" if months > 0
      days = object.time_in_ngo[:days]
      day_string = "#{days} #{'day'.pluralize(days)}" if days > 0
      "#{year_string} #{month_string} #{day_string}".strip()
    end
  end

  def time_in_cps
    cps_lists = {}
    return cps_lists if object.time_in_cps.nil?
    object.time_in_cps.each do |cps|
      unless cps[1].blank?
        years = cps[1][:years]
        year_string = "#{years} #{'year'.pluralize(years)}" if years > 0
        months = cps[1][:months]
        month_string = "#{months} #{'month'.pluralize(months)}" if months > 0
        days = cps[1][:days]
        day_string = "#{days} #{'day'.pluralize(days)}" if days > 0
        cps_lists["#{cps[0]}"] = "#{year_string} #{month_string} #{day_string}".strip()
      end
    end
    cps_lists
  end

  def family_name
    current_org = Organization.current.short_name
    Organization.switch_to 'shared'
    shared_client = SharedClient.find_by(slug: object.slug)
    Organization.switch_to current_org
    shared_client.family_name
  end

  def given_name
    current_org = Organization.current.short_name
    Organization.switch_to 'shared'
    shared_client = SharedClient.find_by(slug: object.slug)
    Organization.switch_to current_org
    shared_client.given_name
  end

  def local_given_name
    current_org = Organization.current.short_name
    Organization.switch_to 'shared'
    shared_client = SharedClient.find_by(slug: object.slug)
    Organization.switch_to current_org
    shared_client.local_given_name
  end

  def local_family_name
    current_org = Organization.current.short_name
    Organization.switch_to 'shared'
    shared_client = SharedClient.find_by(slug: object.slug)
    Organization.switch_to current_org
    shared_client.local_family_name
  end

  def gender
    current_org = Organization.current.short_name
    Organization.switch_to 'shared'
    shared_client = SharedClient.find_by(slug: object.slug)
    Organization.switch_to current_org
    shared_client.gender
  end

  def date_of_birth
    current_org = Organization.current.short_name
    Organization.switch_to 'shared'
    shared_client = SharedClient.find_by(slug: object.slug)
    Organization.switch_to current_org
    shared_client.date_of_birth
  end

  def live_with
    current_org = Organization.current.short_name
    Organization.switch_to 'shared'
    shared_client = SharedClient.find_by(slug: object.slug)
    Organization.switch_to current_org
    shared_client.live_with
  end

  def telephone_number
    current_org = Organization.current.short_name
    Organization.switch_to 'shared'
    shared_client = SharedClient.find_by(slug: object.slug)
    Organization.switch_to current_org
    shared_client.telephone_number
  end

  def birth_province
    current_org = Organization.current.short_name
    Organization.switch_to 'shared'
    birth_province = SharedClient.find_by(slug: object.slug).birth_province
    Organization.switch_to current_org
    birth_province
  end

  def enter_ngos
    object.enter_ngos
  end

  def exit_ngos
    object.exit_ngos
  end

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
      custom_field_property_file_upload = custom_field.custom_field_properties.where(custom_formable_id: object.id)
      custom_field_property_file_upload.each do |custom_field_property|
        custom_field_property.form_builder_attachments.map do |c|
          custom_field_property.properties = custom_field_property.properties.merge({c.name => c.file})
        end
      end
      custom_field.as_json.merge(custom_field_properties: custom_field_property_file_upload.as_json)
    end
  end

  def tasks
    overdue_tasks   = ActiveModel::ArraySerializer.new(object.tasks.overdue_incomplete, each_serializer: TaskSerializer)
    today_tasks     = ActiveModel::ArraySerializer.new(object.tasks.today_incomplete, each_serializer: TaskSerializer)
    upcoming_tasks  = ActiveModel::ArraySerializer.new(object.tasks.incomplete.upcoming, each_serializer: TaskSerializer)
    { overdue: overdue_tasks, today: today_tasks, upcoming: upcoming_tasks }
  end

  def foster_care
    CaseSerializer.new(object.cases.active.latest_foster).serializable_hash
  end

  def kinship_care
    CaseSerializer.new(object.cases.active.latest_kinship).serializable_hash
  end

  def brc_client_address
    fields = %w(current_island current_street current_po_box current_settlement current_resident_own_or_rent current_household_type)
    FieldSetting.by_instances(Apartment::Tenant.current).where(name: fields).any? && fields.any? { |field| show?(field.to_sym) }
  end

  def assessments
    object.assessments.map do |assessment|
      formatted_assessment_domain = assessment.assessment_domains_in_order.map do |ad|
        incomplete_tasks = object.tasks.by_domain_id(ad.domain_id).incomplete
        incomplete_tasks_with_domain = incomplete_tasks.map{ |task| task.as_json(only: [:id, :name, :completion_date]).merge(domain: task.domain.as_json(only: [:id, :name, :identity])) }
        ad.as_json.merge(domain: ad.domain.as_json(only: [:name, :identity]), incomplete_tasks: incomplete_tasks_with_domain)
      end
      assessment.as_json.merge(assessment_domain: formatted_assessment_domain)
    end
  end

  def case_notes
    object.case_notes.most_recents.map do |case_note|
      formatted_case_note_domain_group = case_note.case_note_domain_groups.map do |cdg|
        next if cdg.domain_group.nil?
        domain_scores = cdg.domains(case_note).map do |domain|
          ad = domain.assessment_domains.find_by(assessment_id: case_note.assessment_id)
          ad.try(:score)
          { domain_id: ad.domain_id, score: ad.score } if ad.present?
        end.compact
        cdg.as_json.merge(domain_group_identities: cdg.domain_identities, domain_scores: domain_scores, completed_tasks: cdg.completed_tasks)
      end
      case_note.as_json.merge(case_note_domain_groups: formatted_case_note_domain_group)
    end
  end

  def quantitative_cases
    object.quantitative_cases.group_by(&:quantitative_type).map do |qtype, qcases|
      qtype_name = qtype.name
      qcases = qcases.map { |qcase| qcase.try(:value) || qcases.try(:name) }
      { quantitative_type: qtype_name, client_quantitative_cases: qcases }
    end
  end

  def program_streams
    ProgramStream.active_enrollments(object).map do |program_stream|
      list_program_stream(program_stream)
    end
  end

  def inactive_program_streams
    ProgramStream.inactive_enrollments(object).map do |program_stream|
      list_program_stream(program_stream)
    end
  end

  def add_forms
    custom_field_ids = object.custom_field_properties.pluck(:custom_field_id)
    CustomField.client_forms.not_used_forms(custom_field_ids).order_by_form_title
  end

  def family
    fam = object.family

    { id: fam.try(:id), display_name: fam.try(:display_name) }
  end

  def list_program_stream(program_stream)
    formatted_enrollments = program_stream.client_enrollments.enrollments_by(object).map do |enrollment|
      enrollment.form_builder_attachments.map do |c|
        enrollment.properties = enrollment.properties.merge({c.name => c.file})
      end
      enrollment_field = program_stream.enrollment
      trackings = enrollment.client_enrollment_trackings.map do |tracking|
        tracking.form_builder_attachments.map do |c|
          tracking.properties = tracking.properties.merge({c.name => c.file})
        end
        tracking.as_json.merge(tracking_field: tracking.tracking&.fields || [])
      end
      if enrollment.leave_program.present?
        leave_program = enrollment.leave_program
        leave_program.form_builder_attachments.map do |c|
          leave_program.properties = leave_program.properties.merge({c.name => c.file})
        end
        leave_program = leave_program.as_json.merge(leave_program_field: program_stream.exit_program)
      end
      enrollment.as_json.merge(trackings: trackings, leave_program: leave_program, enrollment_field: enrollment_field)
    end
    domains = program_stream.domains.map(&:identity)
    if program_stream.quantity.present?
      program_stream.quantity = program_stream.number_available_for_entity
    end
    tracking_fields = program_stream.trackings
    program_stream.as_json(only: [:id, :name, :description, :quantity, :tracking_required, :exit_program, :enrollment]).merge(domain: domains, enrollments: formatted_enrollments, tracking_fields: tracking_fields)
  end
end
