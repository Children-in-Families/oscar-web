class ClientSerializer < ActiveModel::Serializer

  attributes  :id, :given_name, :family_name, :gender, :code, :status, :date_of_birth, :grade,
              :current_province, :local_given_name, :local_family_name, :kid_id, :donors,
              :current_address, :house_number, :street_number, :village, :commune, :district, :profile,
              :completed, :birth_province, :initial_referral_date, :referral_source, :what3words, :name_of_referee,
              # :referral_phone, :live_witr, :id_poor, :received_by,
              :referral_phone, :live_with, :received_by, :main_school_contact,  :telephone_number,
              :followed_up_by, :follow_up_date, :school_name, :school_grade, :has_been_in_orphanage,
              :has_been_in_government_care, :relevant_referral_information, :rated_for_id_poor,
              :case_workers, :agencies, :state, :rejected_note, :emergency_care, :foster_care, :kinship_care,
              :organization, :additional_form, :tasks, :assessments, :case_notes, :quantitative_cases,
              :program_streams, :add_forms, :inactive_program_streams, :enter_ngos, :exit_ngos, :time_in_ngo, :time_in_cps, :referral_source_category_id

  has_many :assessments
  has_many :client_enrollments

  def profile
    object.profile.present? ? { uri: object.profile.url } : {}
  end

  def time_in_ngo
    return {} if self.status == 'Referred'
    day_time_in_ngos = calculate_day_time_in_ngo

    if day_time_in_ngos.present?
      years = day_time_in_ngos / 365
      remaining_day_from_year = day_time_in_ngos % 365

      months = remaining_day_from_year / 30
      remaining_day_from_month = remaining_day_from_year % 30
      detail_time_in_ngo = { years: years, months: months, days: remaining_day_from_month }
    end
  end

  def calculate_day_time_in_ngo
    enter_ngos = self.enter_ngos.order(accepted_date: :desc)

    return 0 if (enter_ngos.size.zero?)

    exit_ngos  = self.exit_ngos.order(exit_date: :desc).where("created_at >= ?", enter_ngos.last.created_at)
    enter_ngo_dates = enter_ngos.pluck(:accepted_date)
    exit_ngo_dates  = exit_ngos.pluck(:exit_date)

    exit_ngo_dates.unshift(Date.today) if exit_ngo_dates.size < enter_ngo_dates.size

    day_time_in_ngos = exit_ngo_dates.each_with_index.inject(0) do |sum, (exit_ngo_date, index)|
      enter_ngo_date = enter_ngo_dates[index]
      next_ngo_date = enter_ngo_dates[index + 1]

      if next_ngo_date != enter_ngo_date
        day_in_ngo = (exit_ngo_date - enter_ngo_date).to_i
        sum += day_in_ngo < 0 ? 0 : day_in_ngo + 1
      end
      sum
    end
    day_time_in_ngos
  end

  def time_in_cps
    date_time_in_cps   = { years: 0, months: 0, weeks: 0, days: 0 }
    return nil unless client_enrollments.present?
    enrollments = client_enrollments.order(:program_stream_id)
    detail_cps = {}

    enrollments.each_with_index do |enrollment, index|
      enroll_date     = enrollment.enrollment_date
      current_or_exit = enrollment.leave_program.try(:exit_date) || Date.today

      if enrollments[index - 1].present? && enrollments[index - 1].program_stream_name == enrollment.program_stream_name
        date_time_in_cps = { years: 0, months: 0, weeks: 0, days: 0 }
        date_time_in_cps = calculate_time_in_care(date_time_in_cps, current_or_exit, enroll_date)
      else
        date_time_in_cps = { years: 0, months: 0, weeks: 0, days: 0 }
        date_time_in_cps = calculate_time_in_care(date_time_in_cps, current_or_exit, enroll_date)
      end

      if detail_cps["#{enrollment.program_stream_name}"].present?
        detail_cps["#{enrollment.program_stream_name}"][:years].present? ? detail_cps["#{enrollment.program_stream_name}"][:years] : detail_cps["#{enrollment.program_stream_name}"][:years] = 0
        detail_cps["#{enrollment.program_stream_name}"][:months].present? ? detail_cps["#{enrollment.program_stream_name}"][:months] : detail_cps["#{enrollment.program_stream_name}"][:months] = 0
        detail_cps["#{enrollment.program_stream_name}"][:days].present? ? detail_cps["#{enrollment.program_stream_name}"][:days] : detail_cps["#{enrollment.program_stream_name}"][:days] = 0

        if date_time_in_cps.present?
          detail_cps["#{enrollment.program_stream_name}"][:years] += date_time_in_cps[:years].present? ? date_time_in_cps[:years] : 0
          detail_cps["#{enrollment.program_stream_name}"][:months] += date_time_in_cps[:months].present? ? date_time_in_cps[:months] : 0
          detail_cps["#{enrollment.program_stream_name}"][:days] += date_time_in_cps[:days].present? ? date_time_in_cps[:days] : 0
        end
      else
        detail_cps["#{enrollment.program_stream_name}"] = date_time_in_cps
      end
    end

    detail_cps.values.map do |value|
      next if value.blank?
      value.store(:years, 0) unless value[:years].present?
      value.store(:months, 0) unless value[:months].present?
      value.store(:days, 0) unless value[:days].present?


      if value[:days] > 365
        value[:years] = value[:years] + value[:days]/365
        value[:days] = value[:days] % 365
      elsif value[:days] == 365
        value[:years]  = 1
        value[:days]   = 0
        value[:months] = 0
      end

      if value[:days] > 30
        value[:months] = value[:days] / 30
        value[:days] = value[:days] % 30
      elsif value[:days] == 30
        value[:days] = 0
        value[:months] = 1
      end
    end
    detail_cps
  end

  def calculate_time_in_care(date_time_in_care, from_time, to_time)
    return if from_time.nil? || to_time.nil?
    to_time = to_time + date_time_in_care[:years].years unless date_time_in_care[:years].nil?
    to_time = to_time + date_time_in_care[:months].months unless date_time_in_care[:months].nil?
    to_time = to_time + date_time_in_care[:weeks].weeks unless date_time_in_care[:weeks].nil?
    to_time = to_time + date_time_in_care[:days].days unless date_time_in_care[:days].nil?

    from_time = from_time.to_date
    to_time = to_time.to_date
    if from_time >= to_time
      time_days = (from_time - to_time).to_i + 1
      times = {days: time_days}
    end
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
        tracking.as_json.merge(tracking_field: tracking.tracking.fields)
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
      program_stream.quantity = program_stream.number_available_for_client
    end
    tracking_fields = program_stream.trackings
    program_stream.as_json(only: [:id, :name, :description, :quantity, :tracking_required, :exit_program, :enrollment]).merge(domain: domains, enrollments: formatted_enrollments, tracking_fields: tracking_fields)
  end
end
