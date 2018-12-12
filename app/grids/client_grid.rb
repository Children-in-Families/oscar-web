class ClientGrid < BaseGrid
  extend ActionView::Helpers::TextHelper
  include ClientsHelper
  include ApplicationHelper

  attr_accessor :current_user, :qType, :dynamic_columns, :param_data
  COUNTRY_LANG = { "cambodia" => "(Khmer)", "thailand" => "(Thai)", "myanmar" => "(Burmese)", "lesotho" => "(Sesotho)", "uganda" => "(Swahili)" }

  scope do
    Client.includes(:village, :commune, :district, :referral_source, :received_by, :followed_up_by, :province, :assessments, :enter_ngos, :exit_ngos, :users).order('clients.status, clients.given_name')
  end

  filter(:given_name, :string, header: -> { I18n.t('datagrid.columns.clients.given_name') }) do |value, scope|
    filter_shared_fileds('given_name', value, scope)
  end

  filter(:family_name, :string, header: -> { I18n.t('datagrid.columns.clients.family_name') }) do |value, scope|
    filter_shared_fileds('family_name', value, scope)
  end

  filter(:local_given_name, :string, header: -> { I18n.t('datagrid.columns.clients.local_given_name') }) do |value, scope|
    filter_shared_fileds('local_given_name', value, scope)
  end

  filter(:local_family_name, :string, header: -> { I18n.t('datagrid.columns.clients.local_family_name') }) do |value, scope|
    filter_shared_fileds('local_family_name', value, scope)
  end

  filter(:gender, :enum, select: %w(Male Female Unknown), header: -> { I18n.t('datagrid.columns.clients.gender') }) do |value, scope|
    current_org = Organization.current
    Organization.switch_to 'shared'
    slugs = SharedClient.where(gender: value.downcase).pluck(:slug)
    Organization.switch_to current_org.short_name
    scope.where(slug: slugs)
  end

  filter(:created_at, :date, range: true, header: -> { I18n.t('datagrid.columns.clients.created_at') })

  def self.filter_shared_fileds(field, value, scope)
    current_org = Organization.current
    Organization.switch_to 'shared'
    slugs = SharedClient.where("shared_clients.#{field} ILIKE ?", "%#{value.squish}%").pluck(:slug)
    Organization.switch_to current_org.short_name
    scope.where(slug: slugs)
  end

  filter(:slug, :string, header: -> { I18n.t('datagrid.columns.clients.id')})  { |value, scope| scope.slug_like(value) }

  filter(:code, :integer, header: -> { I18n.t('datagrid.columns.clients.code') }) { |value, scope| scope.start_with_code(value) }

  filter(:kid_id, :string, header: -> { I18n.t('datagrid.columns.clients.kid_id') })

  filter(:status, :enum, select: :status_options, header: -> { I18n.t('datagrid.columns.clients.status') })

  # filter(:house_number, :string)

  def status_options
    scope.status_like
  end


  filter(:date_of_birth, :date, range: true, header: -> { I18n.t('datagrid.columns.clients.date_of_birth') })

  filter(:age, :float, range: true, header: -> { I18n.t('datagrid.columns.clients.age') }) do |value, scope|
    scope.age_between(value[0], value[1]) if value[0].present? && value[1].present?
  end

  filter(:has_date_of_birth, :enum, select: :has_or_has_no_dob, header: -> { I18n.t('datagrid.columns.clients.has_date_of_birth') }) do |value, scope|
    value == 'Yes' ? scope.where.not(date_of_birth: nil) : scope.where(date_of_birth: nil)
  end

  def has_or_has_no_dob
    [[I18n.t('datagrid.columns.clients.has_dob'), 'Yes'], [I18n.t('datagrid.columns.clients.no_dob'), 'No']]
  end

  filter(:birth_province_id, :enum, select: :province_with_birth_place, header: -> { I18n.t('datagrid.columns.clients.birth_province') })
  def province_with_birth_place
    Province.birth_places.map { |p| [p.name, p.id] }
  end

  filter(:province_id, :enum, select: :province_with_clients, header: -> { I18n.t('datagrid.columns.clients.current_province') })

  def province_with_clients
    Province.has_clients.map { |p| [p.name, p.id] }
  end

  filter(:telephone_number, :string, header: -> { I18n.t('datagrid.columns.clients.telephone_number') })

  filter(:live_with, :string, header: -> { I18n.t('datagrid.columns.clients.live_with') })

  # filter(:id_poor, :integer, header: -> { I18n.t('datagrid.columns.clients.id_poor') })

  filter(:initial_referral_date, :date, range: true, header: -> { I18n.t('datagrid.columns.clients.initial_referral_date') })

  filter(:referral_phone, :string, header: -> { I18n.t('datagrid.columns.clients.referral_phone') })

  filter(:received_by_id, :enum, select: :is_received_by_options, header: -> { I18n.t('datagrid.columns.clients.received_by') })

  filter(:referred_to, :enum, select: :referral_to_options, header: -> { I18n.t('datagrid.columns.clients.referred_to') } )

  filter(:referred_from, :enum, select: :referral_from_options, header: -> { I18n.t('datagrid.columns.clients.referred_from') } )

  def referral_to_options
    orgs = Organization.oscar.map { |org| { org.short_name => org.full_name } }
    orgs << { "external referral" => "I don't see the NGO I'm looking for" }
  end

  def referral_from_options
    Organization.oscar.map { |org| { org.short_name => org.full_name } }
  end

  def is_received_by_options
    current_user.present? ? Client.joins(:case_worker_clients).where(case_worker_clients: { user_id: current_user.id }).is_received_by : Client.is_received_by
  end
  # Client.joins(:case_worker_clients).where(case_worker_clients: { user_id: current_user.id })

  filter(:referral_source_id, :enum, select: :referral_source_options, header: -> { I18n.t('datagrid.columns.clients.referral_source') })

  def referral_source_options
    current_user.present? ? Client.joins(:case_worker_clients).where(case_worker_clients: { user_id: current_user.id }).referral_source_is : Client.referral_source_is
  end

  filter(:followed_up_by_id, :enum, select: :is_followed_up_by_options, header: -> { I18n.t('datagrid.columns.clients.follow_up_by') })

  def is_followed_up_by_options
    current_user.present? ? Client.joins(:case_worker_clients).where(case_worker_clients: { user_id: current_user.id }).is_followed_up_by : Client.is_followed_up_by
  end

  filter(:follow_up_date, :date, range: true, header: -> { I18n.t('datagrid.columns.clients.follow_up_date') })

  def agencies_options
    Agency.joins(:clients).pluck(:name).uniq
  end

  filter(:agencies_name, :enum, multiple: true, select: :agencies_options, header: -> { I18n.t('datagrid.columns.clients.agency_names') }) do |name, scope|
    if agencies ||= Agency.name_like(name)
      scope.joins(:agencies).where(agencies: { id: agencies.ids })
    else
      scope.joins(:agencies).where(agencies: { id: nil })
    end
  end

  filter(:current_address, :string, header: -> { I18n.t('datagrid.columns.clients.current_address') })

  filter(:house_number, :string, header: -> { I18n.t('datagrid.columns.clients.house_number') })

  filter(:street_number, :string, header: -> { I18n.t('datagrid.columns.clients.street_number') })

  filter(:village, :string, header: -> { I18n.t('datagrid.columns.clients.village') })

  filter(:commune, :string, header: -> { I18n.t('datagrid.columns.clients.commune') })

  filter(:district, :string, header: -> { I18n.t('datagrid.columns.clients.district') })

  filter(:school_name, :string, header: -> { I18n.t('datagrid.columns.clients.school_name') })

  filter(:has_been_in_government_care, :xboolean, header: -> { I18n.t('datagrid.columns.clients.has_been_in_government_care') })

  filter(:school_grade, :string, header: -> { I18n.t('datagrid.columns.clients.school_grade') })

  filter(:has_been_in_orphanage, :xboolean, header: -> { I18n.t('datagrid.columns.clients.has_been_in_orphanage') })

  filter(:relevant_referral_information, :string, header: -> { I18n.t('datagrid.columns.clients.relevant_referral_information') })

  filter(:created_by, :enum, select: :user_select_options, header: -> { I18n.t('datagrid.columns.clients.created_by') })

  filter(:user_ids, :enum, multiple: true, select: :case_worker_options, header: -> { I18n.t('datagrid.columns.clients.case_worker') }) do |ids, scope|
    ids = ids.map{ |id| id.to_i }
    if user_ids ||= User.where(id: ids).ids
      client_ids = Client.joins(:users).where(users: { id: user_ids }).ids.uniq
      scope.where(id: client_ids)
    else
      scope.joins(:users).where(users: { id: nil })
    end
  end

  def user_select_options
    User.non_strategic_overviewers.order(:first_name, :last_name).map { |user| { user.id.to_s => user.name } }
  end

  def case_worker_options
    User.has_clients.map { |user| ["#{user.first_name} #{user.last_name}", user.id] }
  end

  filter(:donors_name, :enum, select: :donor_select_options, header: -> { I18n.t('datagrid.columns.clients.donor') })

  def donor_select_options
    Donor.has_clients.map { |donor| [donor.name, donor.id] }
  end

  # filter(:state, :enum, select: %w(Accepted Rejected), header: -> { I18n.t('datagrid.columns.clients.state') }) do |value, scope|
  #   value == 'Accepted' ? scope.accepted : scope.rejected
  # end

  def quantitative_type_options
    QuantitativeType.all.map{ |t| [t.name, t.id] }
  end

  filter(:quantitative_types, :enum, select: :quantitative_type_options, header: -> { I18n.t('datagrid.columns.clients.quantitative_types') }) do |value, scope|
    ids = Client.joins(:quantitative_cases).where(quantitative_cases: { quantitative_type_id: value.to_i }).pluck(:id).uniq
    scope.where(id: ids)
  end

  def quantitative_cases
    qType.present? ? QuantitativeType.find(qType.to_i).quantitative_cases.map{ |t| [t.value, t.id] } : QuantitativeCase.all.map{ |t| [t.value, t.id] }
  end

  filter(:quantitative_data, :enum, select: :quantitative_cases, header: -> { I18n.t('datagrid.columns.clients.quantitative_case_values') }) do |value, scope|
    ids = Client.joins(:quantitative_cases).where(quantitative_cases: { id: value.to_i }).pluck(:id).uniq
    scope.where(id: ids)
  end

  # filter(:any_assessments, :enum, select: %w(Yes No), header: -> { I18n.t('datagrid.columns.clients.any_assessments') }) do |value, scope|
  #   if value == 'Yes'
  #     client_ids = Client.joins(:assessments).uniq.pluck(:id)
  #     scope.where(id: client_ids)
  #   else
  #     scope.without_assessments
  #   end
  # end

  filter(:assessments_due_to, :enum, select: Assessment::DUE_STATES, header: -> { I18n.t('datagrid.columns.clients.assessments_due_to') }) do |value, scope|
    ids = []
    setting = Setting.first
    if value == Assessment::DUE_STATES[0]
      Client.active_accepted_status.each do |c|
        next if !c.eligible_default_csi? && !c.eligible_custom_csi?
        if setting.enable_default_assessment? && setting.enable_custom_assessment?
          ids << c.id if c.next_assessment_date == Date.today || c.custom_next_assessment_date == Date.today
        elsif setting.enable_default_assessment?
          ids << c.id if c.next_assessment_date == Date.today
        elsif setting.enable_custom_assessment?
          ids << c.id if c.custom_next_assessment_date == Date.today
        end
      end
    else
      Client.joins(:assessments).active_accepted_status.each do |c|
        next if !c.eligible_default_csi? && !c.eligible_custom_csi?
        if setting.enable_default_assessment? && setting.enable_custom_assessment?
          ids << c.id if c.next_assessment_date  < Date.today || c.custom_next_assessment_date  < Date.today
        elsif setting.enable_default_assessment?
          ids << c.id if c.next_assessment_date  < Date.today
        elsif setting.enable_custom_assessment?
          ids << c.id if c.custom_next_assessment_date  < Date.today
        end
      end
    end
    scope.where(id: ids)
  end

  filter(:all_domains, :dynamic, select: ['All CSI'], header: -> { I18n.t('datagrid.columns.clients.domains') }) do |(field, operation, value), scope|
    value = value.to_i
    assessment_id = []
    AssessmentDomain.all.group_by(&:assessment_id).each do |key, ad|
      arr = []
      a_id = []
      ad.each do |v|
        if operation == '='
          arr.push v.score == value.to_i ? true : false
        else
          arr.push eval("#{v.score}#{operation}#{value}") ? true : false
        end
        a_id.push v.assessment_id
      end
      if !arr.include?(false)
        assessment_id.push a_id[0]
      end
    end
    scope.joins(:assessments).where(assessments: { id: assessment_id })
  end

  def self.client_by_domain(operation, value, domain_id, scope)
    ids = Assessment.joins(:assessment_domains).where("score#{operation} ? AND domain_id= ?", value, domain_id).ids
    scope.joins(:assessments).where(assessments: { id: ids})
  end

  def self.get_domain(name)
    domain = Domain.find_by(name: name)
    domain.present?  ? Array.new([[domain.name, domain.id]]) : []
  end

  filter(:domain_1a, :dynamic, select: proc { get_domain('1A') }, header: -> { "#{ I18n.t('datagrid.columns.clients.domain')} 1A (Food Security)" }) do |(domain_id, operation, value), scope|
    value = value.to_i
    client_by_domain(operation, value, domain_id, scope)
  end

  filter(:domain_1b, :dynamic, select: proc { get_domain('1B') }, header: -> { "#{ I18n.t('datagrid.columns.clients.domain')} 1B (Nutrition and Growth)" }) do |(domain_id, operation, value), scope|
    value = value.to_i
    client_by_domain(operation, value, domain_id, scope)
  end

  filter(:domain_2a, :dynamic, select: proc { get_domain('2A') }, header: -> { "#{ I18n.t('datagrid.columns.clients.domain')} 2A (Shelter)" }) do |(domain_id, operation, value), scope|
    value = value.to_i
    client_by_domain(operation, value, domain_id, scope)
  end

  filter(:domain_2b, :dynamic, select: proc { get_domain('2B') }, header: -> { "#{ I18n.t('datagrid.columns.clients.domain')} 2B (Care)" }) do |(domain_id, operation, value), scope|
    value = value.to_i
    client_by_domain(operation, value, domain_id, scope)
  end

  filter(:domain_3a, :dynamic, select: proc { get_domain('3A') }, header: -> { "#{ I18n.t('datagrid.columns.clients.domain')} 3A (Protection from Abuse and Exploitation)" }) do |(domain_id, operation, value), scope|
    value = value.to_i
    client_by_domain(operation, value, domain_id, scope)
  end

  filter(:domain_3b, :dynamic, select: proc { get_domain('3B') }, header: -> { "#{ I18n.t('datagrid.columns.clients.domain')} 3B (Legal Protection)" }) do |(domain_id, operation, value), scope|
    value = value.to_i
    client_by_domain(operation, value, domain_id, scope)
  end

  filter(:domain_4a, :dynamic, select: proc { get_domain('4A') }, header: -> { "#{ I18n.t('datagrid.columns.clients.domain')} 4A (Wellness)" }) do |(domain_id, operation, value), scope|
    value = value.to_i
    client_by_domain(operation, value, domain_id, scope)
  end

  filter(:domain_4b, :dynamic, select: proc { get_domain('4B') }, header: -> { "#{ I18n.t('datagrid.columns.clients.domain')} 4B (Health Care Services)" }) do |(domain_id, operation, value), scope|
    value = value.to_i
    client_by_domain(operation, value, domain_id, scope)
  end

  filter(:domain_5a, :dynamic, select: proc { get_domain('5A') }, header: -> { "#{ I18n.t('datagrid.columns.clients.domain')} 5A (Emotional Health)" }) do |(domain_id, operation, value), scope|
    value = value.to_i
    client_by_domain(operation, value, domain_id, scope)
  end

  filter(:domain_5b, :dynamic, select: proc { get_domain('5B') }, header: -> { "#{ I18n.t('datagrid.columns.clients.domain')} 5B (Social Behaviour)" }) do |(domain_id, operation, value), scope|
    value = value.to_i
    client_by_domain(operation, value, domain_id, scope)
  end

  filter(:domain_6a, :dynamic, select: proc { get_domain('6A') }, header: -> { "#{ I18n.t('datagrid.columns.clients.domain')} 6A (Performance)" }) do |(domain_id, operation, value), scope|
    value = value.to_i
    client_by_domain(operation, value, domain_id, scope)
  end

  filter(:domain_6b, :dynamic, select: proc { get_domain('6B') }, header: -> { "#{ I18n.t('datagrid.columns.clients.domain')} 6B (Work and Education)" }) do |(domain_id, operation, value), scope|
    value = value.to_i
    client_by_domain(operation, value, domain_id, scope)
  end

  filter(:program_streams, :enum, multiple: true, select: :program_stream_options, header: -> { I18n.t('datagrid.columns.clients.program_streams') }) do |name, scope|
    program_stream_ids = ProgramStream.name_like(name).ids
    ids = Client.joins(:client_enrollments).where(client_enrollments: { program_stream_id: program_stream_ids } ).pluck(:id).uniq
    scope.where(id: ids)
  end

  def program_stream_options
    ProgramStream.joins(:client_enrollments).complete.ordered.pluck(:name).uniq
  end

  # implementation is in client_association_filter.rb
  filter(:accepted_date, :date, range: true, header: -> { I18n.t('datagrid.columns.clients.ngo_accepted_date') })

  # implementation is in client_association_filter.rb
  filter(:exit_date, :date, range: true, header: -> { I18n.t('datagrid.columns.clients.ngo_exit_date') })

  filter(:no_case_note, :enum, select: %w(Yes No), header: -> { I18n.t('datagrid.form.no_case_note') }) do |value, scope|
    if value == 'Yes'
      scope.joins(:case_notes).where(case_notes: { id: case_note_overdue_ids })
    end
  end

  def self.case_note_overdue_ids
    setting = Setting.first
    max_case_note = setting.try(:max_case_note) || 30
    case_note_frequency = setting.try(:case_note_frequency) || 'day'
    case_note_period = max_case_note.send(case_note_frequency).ago
    CaseNote.no_case_note_in(case_note_period).ids
  end

  filter(:overdue_task, :enum, select: %w(Overdue), header: -> { I18n.t('datagrid.form.has_overdue_task') }) do |value, scope|
    if value == 'Overdue'
      client_ids = Task.overdue_incomplete.pluck(:client_id)
      scope.where(id: client_ids)
    end
  end

  filter(:overdue_forms, :enum, select: %w(Yes No), header: -> { I18n.t('datagrid.form.has_overdue_forms') }) do |value, scope|
    if value == 'Yes'
      client_ids = []
      clients = Client.joins(:custom_fields).where.not(custom_fields: { frequency: '' }) + Client.joins(:client_enrollments).where(client_enrollments: { status: 'Active' })
      clients.uniq.each do |client|
        custom_fields = client.custom_fields.where.not(frequency: '')
        custom_fields.each do |custom_field|
          client_ids << client.id if client.next_custom_field_date(client, custom_field) < Date.today
        end
        client_active_enrollments = client.client_enrollments.active
        client_active_enrollments.each do |client_active_enrollment|
          next unless client_active_enrollment.program_stream.tracking_required?
          trackings = client_active_enrollment.trackings.where.not(frequency: '')
          trackings.each do |tracking|
            last_client_enrollment_tracking = client_active_enrollment.client_enrollment_trackings.last
            client_ids << client.id if client.next_client_enrollment_tracking_date(tracking, last_client_enrollment_tracking) < Date.today
          end
        end
      end
      scope.where(id: client_ids.uniq)
    end
  end

  column(:slug, order:'clients.id', header: -> { I18n.t('datagrid.columns.clients.id') })

  column(:code, header: -> { I18n.t('datagrid.columns.clients.code') }) do |object|
    object.code ||= ''
  end

  column(:kid_id, order:'clients.kid_id', header: -> { I18n.t('datagrid.columns.clients.kid_id') })

  column(:given_name, order: 'clients.given_name', header: -> { I18n.t('datagrid.columns.clients.given_name') }, html: true) do |object|
    current_org = Organization.current
    Organization.switch_to 'shared'
    given_name = SharedClient.find_by(slug: object.slug).given_name
    Organization.switch_to current_org.short_name
    if given_name.present?
      link_to given_name, client_path(object), target: :_blank
    else
      given_name
    end
  end

  column(:given_name, header: -> { I18n.t('datagrid.columns.clients.given_name') }, html: false) do |object|
    current_org = Organization.current
    Organization.switch_to 'shared'
    given_name = SharedClient.find_by(slug: object.slug).given_name
    Organization.switch_to current_org.short_name
    given_name
  end

  column(:family_name, order: 'clients.family_name', header: -> { I18n.t('datagrid.columns.clients.family_name') }) do |object|
    current_org = Organization.current
    Organization.switch_to 'shared'
    family_name = SharedClient.find_by(slug: object.slug).family_name
    Organization.switch_to current_org.short_name
    family_name
  end

  def self.dynamic_local_name
    country = Organization.current.short_name == 'cccu' ? 'uganda' : Setting.first.country_name
    I18n.locale.to_s == 'en' ? COUNTRY_LANG[country] : ''
  end

  column(:local_given_name, order: 'clients.local_given_name', header: -> { "#{I18n.t('datagrid.columns.clients.local_given_name')} #{ dynamic_local_name }" }) do |object|
    current_org = Organization.current
    Organization.switch_to 'shared'
    local_given_name = SharedClient.find_by(slug: object.slug).local_given_name
    Organization.switch_to current_org.short_name
    local_given_name
  end

  column(:local_family_name, order: 'clients.local_family_name', header: -> { "#{I18n.t('datagrid.columns.clients.local_family_name')} #{ dynamic_local_name }" }) do |object|
    current_org = Organization.current
    Organization.switch_to 'shared'
    local_family_name = SharedClient.find_by(slug: object.slug).local_family_name
    Organization.switch_to current_org.short_name
    local_family_name
  end

  column(:gender, header: -> { I18n.t('datagrid.columns.clients.gender') }) do |object|
    current_org = Organization.current
    Organization.switch_to 'shared'
    gender = SharedClient.find_by(slug: object.slug).gender.try(:titleize)
    Organization.switch_to current_org.short_name
    gender
  end

  column(:status, header: -> { I18n.t('datagrid.columns.clients.status') }) do |object|
    format(object.status) do |value|
      status_style(value)
    end
  end

  column(:telephone_number, header: -> { I18n.t('datagrid.columns.cases.telephone_number') }) do |object|
    current_org = Organization.current
    Organization.switch_to 'shared'
    telephone_number = SharedClient.find_by(slug: object.slug).telephone_number
    Organization.switch_to current_org.short_name
    telephone_number
  end

  column(:live_with, header: -> { I18n.t('datagrid.columns.clients.live_with') }) do |object|
    current_org = Organization.current
    Organization.switch_to 'shared'
    live_with = SharedClient.find_by(slug: object.slug).live_with
    Organization.switch_to current_org.short_name
    live_with
  end

  # column(:id_poor, header: -> { I18n.t('datagrid.columns.clients.id_poor') })

  dynamic do
    quantitative_type_readable_ids = current_user.quantitative_type_permissions.readable.pluck(:quantitative_type_id) unless current_user.nil?
    QuantitativeType.joins(:quantitative_cases).uniq.each do |quantitative_type|
      if current_user.nil? || quantitative_type_readable_ids.include?(quantitative_type.id)
        column(quantitative_type.name.to_sym, class: 'quantitative-type', header: -> { quantitative_type.name }) do |object|
          object.quantitative_cases.where(quantitative_type_id: quantitative_type.id).pluck(:value).join(', ')
        end
      end
    end
  end

  date_column(:follow_up_date, header: -> { I18n.t('datagrid.columns.clients.follow_up_date') })

  column(:program_streams, html: true, order: false, header: -> { I18n.t('datagrid.columns.clients.program_streams') }) do |object|
    render partial: 'clients/active_client_enrollments', locals: { active_programs: object.client_enrollments.active }
  end

  column(:received_by, order: 'users.first_name, users.last_name', html: true, header: -> { I18n.t('datagrid.columns.clients.received_by') }) do |object|
    render partial: 'clients/users', locals: { object: object.received_by } if object.received_by
  end

  column(:received_by, html: false, header: -> { I18n.t('datagrid.columns.clients.received_by') }) do |object|
    object.received_by.try(:name)
  end

  column(:followed_up_by, order: 'users.first_name, users.last_name', html: true, header: -> { I18n.t('datagrid.columns.clients.followed_up_by') }) do |object|
    render partial: 'clients/users', locals: { object: object.followed_up_by } if object.followed_up_by
  end

  column(:followed_up_by, html: false, header: -> { I18n.t('datagrid.columns.clients.followed_up_by') }) do |object|
    object.followed_up_by.try(:name)
  end

  column(:referred_to, order: false, header: -> { I18n.t('datagrid.columns.clients.referred_to') }) do |object|
    short_names = object.referrals.pluck(:referred_to)
    org_names   = Organization.where("organizations.short_name IN (?)", short_names).pluck(:full_name)
    short_names.include?('external referral') ? org_names << "I don't see the NGO I'm looking for" : org_names
    org_names.join(', ')
  end

  column(:referred_from, order: false, header: -> { I18n.t('datagrid.columns.clients.referred_from') }) do |object|
    short_names = object.referrals.pluck(:referred_from)
    Organization.where("organizations.short_name IN (?)", short_names).pluck(:full_name).join(', ')
  end

  column(:agency, order: false, header: -> { I18n.t('datagrid.columns.clients.agencies_involved') }) do |object|
    object.agencies.pluck(:name).join(', ')
  end

  column(:date_of_birth, header: -> { I18n.t('datagrid.columns.clients.date_of_birth') }) do |object|
    current_org = Organization.current
    Organization.switch_to 'shared'
    date_of_birth = SharedClient.find_by(slug: object.slug).date_of_birth
    Organization.switch_to current_org.short_name
    date_of_birth.present? ? date_of_birth.strftime("%d %B %Y") : ''
  end

  column(:age, header: -> { I18n.t('datagrid.columns.clients.age') }, order: 'clients.date_of_birth desc') do |object|
    pluralize(object.age_as_years, 'year') + ' ' + pluralize(object.age_extra_months, 'month') if object.date_of_birth.present?
  end

  date_column(:created_at, header: -> { I18n.t('datagrid.columns.clients.created_at') })

  column(:created_by, header: -> { I18n.t('datagrid.columns.clients.created_by') }) do |object|
    version = object.versions.find_by(event: 'create')
    if version.present? && version.whodunnit.present?
      version.whodunnit.include?('rotati') ? 'OSCaR Team' : User.find_by(id: version.whodunnit.to_i).try(:name)
    else
      'OSCaR Team'
    end
  end

  dynamic do
    country = Setting.first.try(:country_name) || 'cambodia'
    case country
    when 'cambodia'
      column(:current_address, order: 'clients.current_address', header: -> { I18n.t('datagrid.columns.clients.current_address') })

      column(:house_number, header: -> { I18n.t('datagrid.columns.clients.house_number') })

      column(:street_number, header: -> { I18n.t('datagrid.columns.clients.street_number') })

      column(:village, order: 'villages.name_kh', header: -> { I18n.t('datagrid.columns.clients.village') } ) do |object|
        object.village.try(:code_format)
      end

      column(:commune, order: 'communes.name_kh', header: -> { I18n.t('datagrid.columns.clients.commune') } ) do |object|
        object.commune.try(:name)
      end

      column(:district, order: 'districts.name', header: -> { I18n.t('datagrid.columns.clients.district') }) do |object|
        object.district_name
      end

      column(:province, order: 'provinces.name', header: -> { I18n.t('datagrid.columns.clients.current_province') }) do |object|
        object.province_name
      end

      column(:birth_province, header: -> { I18n.t('datagrid.columns.clients.birth_province') }) do |object|
        current_org = Organization.current
        Organization.switch_to 'shared'
        birth_province = SharedClient.find_by(slug: object.slug).birth_province_name
        Organization.switch_to current_org.short_name
        birth_province
      end
    when 'thailand'
      column(:plot, header: -> { I18n.t('datagrid.columns.clients.plot') })

      column(:road, header: -> { I18n.t('datagrid.columns.clients.road') })

      column(:postal_code, header: -> { I18n.t('datagrid.columns.clients.postal_code') })

      column(:district, order: 'districts.name', header: -> { I18n.t('datagrid.columns.clients.district') }) do |object|
        object.district_name
      end

      column(:subdistrict, order: 'subdistrict.name', header: -> { I18n.t('datagrid.columns.clients.subdistrict')}) do |object|
        object.subdistrict_name
      end

      column(:province, order: 'provinces.name', header: -> { I18n.t('datagrid.columns.clients.current_province') }) do |object|
        object.province_name
      end

      column(:birth_province, header: -> { I18n.t('datagrid.columns.clients.birth_province') }) do |object|
        current_org = Organization.current
        Organization.switch_to 'shared'
        birth_province = SharedClient.find_by(slug: object.slug).birth_province_name
        Organization.switch_to current_org.short_name
        birth_province
      end
    when 'lesotho'
      column(:suburb, header: -> { I18n.t('datagrid.columns.clients.suburb') })

      column(:description_house_landmark,  header: -> { I18n.t('datagrid.columns.clients.description_house_landmark') })

      column(:directions, header: -> { I18n.t('datagrid.columns.clients.directions') })
    when 'myanmar'
      column(:street_line1, header: -> { I18n.t('datagrid.columns.clients.street_line1') })

      column(:street_line2, header: -> { I18n.t('datagrid.columns.clients.street_line2') })

      column(:township, order: 'township.name', header: -> { I18n.t('datagrid.columns.clients.township')}) do |object|
        object.township_name
      end

      column(:state, order: 'state.name', header: -> { I18n.t('datagrid.columns.clients.state')}) do |object|
        object.state_name
      end
    end
  end

  column(:school_name, header: -> { I18n.t('datagrid.columns.clients.school_name') })

  column(:school_grade, header: -> { I18n.t('datagrid.columns.clients.school_grade') })

  column(:has_been_in_orphanage, header: -> { I18n.t('datagrid.columns.clients.has_been_in_orphanage') }) do |object|
    object.has_been_in_orphanage.nil? ? '' : object.has_been_in_orphanage? ? 'Yes' : 'No'
  end

  column(:has_been_in_government_care, header: -> { I18n.t('datagrid.columns.clients.has_been_in_government_care') }) do |object|
    object.has_been_in_government_care.nil? ? '' : object.has_been_in_government_care? ? 'Yes' : 'No'
  end

  date_column(:initial_referral_date, header: -> { I18n.t('datagrid.columns.clients.initial_referral_date') })

  column(:relevant_referral_information, header: -> { I18n.t('datagrid.columns.clients.relevant_referral_information') })

  column(:referral_phone, header: -> { I18n.t('datagrid.columns.clients.referral_phone') })

  column(:referral_source, order: 'referral_sources.name', header: -> { I18n.t('datagrid.columns.clients.referral_source') }) do |object|
    object.referral_source.try(:name)
  end

  # column(:state, header: -> { I18n.t('datagrid.columns.clients.state') }) do |object|
  #   object.state.titleize
  # end

  column(:accepted_date, order: false, header: -> { I18n.t('datagrid.columns.clients.ngo_accepted_date') }, html: true) do |object|
    render partial: 'clients/accepted_dates', locals: { object: object }
  end

  column(:exit_date, order: false, header: -> { I18n.t('datagrid.columns.clients.ngo_exit_date') }, html: true) do |object|
    render partial: 'clients/exit_dates', locals: { object: object }
  end

  column(:rejected_note, header: -> { I18n.t('datagrid.columns.clients.rejected_note') })

  # column(:user, order: proc { |scope| scope.joins(:user).reorder('users.first_name') }, header: -> { I18n.t('datagrid.columns.clients.case_worker_or_staff') }) do |object|
  #   object.user.try(:name)
  # end

  column(:exit_circumstance, order: false, html: true, header: -> { I18n.t('datagrid.columns.clients.exit_circumstance') }) do |object|
    render partial: 'clients/exit_circumstances', locals: { object: object }
  end

  column(:exit_reasons, order: false, html: true, header: -> { I18n.t('datagrid.columns.clients.exit_reasons') }) do |object|
    render partial: 'clients/exit_reasons', locals: { object: object }
  end

  column(:other_info_of_exit, order: false, html: true, header: -> { I18n.t('datagrid.columns.clients.other_info_of_exit') }) do |object|
    render partial: 'clients/other_info_of_exits', locals: { object: object }
  end

  column(:exit_note, order: false, html: true, header: -> { I18n.t('datagrid.columns.clients.exit_note') }) do |object|
    render partial: 'clients/exit_notes', locals: { object: object }
  end

  column(:what3words, header: -> { I18n.t('datagrid.columns.clients.what3words') }) do |object|
    object.what3words
  end

  column(:name_of_referee, header: -> { I18n.t('datagrid.columns.clients.name_of_referee') }) do |object|
    object.name_of_referee
  end

  column(:main_school_contact, header: -> { I18n.t('datagrid.columns.clients.main_school_contact') }) do |object|
    object.main_school_contact
  end

  column(:rated_for_id_poor, header: -> { I18n.t('datagrid.columns.clients.rated_for_id_poor') }) do |object|
    object.rated_for_id_poor
  end

  column(:user, order: false, header: -> { I18n.t('datagrid.columns.clients.case_worker_or_staff') }) do |object|
    object.users.pluck(:first_name, :last_name).map{ |case_worker| "#{case_worker.first} #{case_worker.last}".squish }.join(', ')
  end

  column(:donor, order: false, header: -> { I18n.t('datagrid.columns.clients.donor')}) do |object|
    object.donors.pluck(:name).join(', ')
  end

  column(:family_id, order: false, header: -> { I18n.t('datagrid.columns.families.code') }) do |object|
    Family.where('children @> ARRAY[?]::integer[]', [object.id]).pluck(:id).uniq.join(', ')
  end

  column(:family, order: false, header: -> { I18n.t('datagrid.columns.clients.placements.family') }) do |object|
    Family.where('children @> ARRAY[?]::integer[]', [object.id]).pluck(:name).uniq.join(', ')
  end

  column(:case_note_date, header: -> { I18n.t('datagrid.columns.clients.case_note_date')}, html: true) do |object|
    render partial: 'clients/case_note_date', locals: { object: object }
  end

  column(:case_note_type, header: -> { I18n.t('datagrid.columns.clients.case_note_type')}, html: true) do |object|
    render partial: 'clients/case_note_type', locals: { object: object }
  end

  column(:date_of_assessments, header: -> { I18n.t('datagrid.columns.clients.date_of_assessments') }, html: true) do |object|
    render partial: 'clients/assessments', locals: { object: object.assessments.defaults }
  end

  column(:date_of_custom_assessments, header: -> { I18n.t('datagrid.columns.clients.date_of_custom_assessments') }, html: true) do |object|
    render partial: 'clients/assessments', locals: { object: object.assessments.customs }
  end

  # column(:date_of_assessments, header: -> { I18n.t('datagrid.columns.clients.date_of_assessments')}, html: false) do |object|
  #   object.assessments.most_recents.map{ |a| a.created_at.to_date }.join(' | ') if object.assessments.any?
  # end

  column(:time_in_care, header: -> { I18n.t('datagrid.columns.clients.time_in_care') }) do |object|
    if object.time_in_care.present?
      time_in_care = object.time_in_care
      years = I18n.t('clients.show.time_in_care_around.year', count: time_in_care[:years]) if time_in_care[:years] > 0
      months = I18n.t('clients.show.time_in_care_around.month', count: time_in_care[:months]) if time_in_care[:months] > 0
      weeks = I18n.t('clients.show.time_in_care_around.week', count: time_in_care[:weeks]) if time_in_care[:weeks] > 0
      [years, months, weeks].join(' ')
    end
  end

  dynamic do
    if enable_default_assessment?
      column(:all_csi_assessments, header: -> { I18n.t('datagrid.columns.clients.all_csi_assessments') }, html: true) do |object|
        render partial: 'clients/all_csi_assessments', locals: { object: object.assessments.defaults }
      end

      Domain.csi_domains.order_by_identity.each do |domain|
        identity = domain.identity
        column(domain.convert_identity.to_sym, class: 'domain-scores', header: identity, html: true) do |client|
          assessment = client.assessments.defaults.latest_record
          assessment.assessment_domains.find_by(domain_id: domain.id).try(:score) if assessment.present?
        end
      end
    end

    if enable_custom_assessment?
      column(:all_custom_csi_assessments, header: -> { I18n.t('datagrid.columns.clients.all_custom_csi_assessments') }, html: true) do |object|
        render partial: 'clients/all_csi_assessments', locals: { object: object.assessments.customs }
      end

      Domain.custom_csi_domains.order_by_identity.each do |domain|
        identity = domain.identity
        column("custom_#{domain.convert_identity}".to_sym, class: 'domain-scores', header: identity, html: true) do |client|
          assessment = client.assessments.customs.latest_record
          assessment.assessment_domains.find_by(domain_id: domain.id).try(:score) if assessment.present?
        end
      end
    end
  end

  dynamic do
    next unless dynamic_columns.present?
    data = param_data.presence
    dynamic_columns.each do |column_builder|
      fields = column_builder[:id].gsub('&qoute;', '"').split('_')
      column(column_builder[:id].to_sym, class: 'form-builder', header: -> { form_builder_format_header(fields) }, html: true) do |object|
        format_field_value = fields.last.gsub("'", "''").gsub('&qoute;', '"').gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
        if fields.first == 'formbuilder'
          if data == 'recent'
            if fields.last == 'Has This Form'
              properties = object.custom_field_properties.joins(:custom_field).where(custom_fields: { form_title: fields.second, entity_type: 'Client'}).count
            else
              properties = object.custom_field_properties.joins(:custom_field).where(custom_fields: { form_title: fields.second, entity_type: 'Client'}).order(created_at: :desc).first.try(:properties)
              properties = properties[format_field_value] if properties.present?
            end
          else
            if fields.last == 'Has This Form'
              properties = [object.custom_field_properties.joins(:custom_field).where(custom_fields: { form_title: fields.second, entity_type: 'Client'}).count]
            else
              properties = object.custom_field_properties.joins(:custom_field).where(custom_fields: { form_title: fields.second, entity_type: 'Client'}).properties_by(format_field_value)
            end
          end
        elsif fields.first == 'enrollmentdate'
          if data == 'recent'
            properties = date_format(object.client_enrollments.joins(:program_stream).where(program_streams: { name: fields.second }).order(enrollment_date: :desc).first.try(:enrollment_date))
          else
            properties = date_filter(object.client_enrollments.joins(:program_stream).where(program_streams: { name: fields.second }), fields.join('_')).map{|date| date_format(date.enrollment_date) }
          end
        elsif fields.first == 'enrollment'
          if data == 'recent'
            properties = object.client_enrollments.joins(:program_stream).where(program_streams: { name: fields.second }).order(enrollment_date: :desc).first.try(:properties)
            properties = properties[format_field_value] if properties.present?
          else
            properties = object.client_enrollments.joins(:program_stream).where(program_streams: { name: fields.second }).properties_by(format_field_value)
          end
        elsif fields.first == 'tracking'
          ids = object.client_enrollments.ids
          if data == 'recent'
            properties = ClientEnrollmentTracking.joins(:tracking).where(trackings: { name: fields.third }, client_enrollment_trackings: { client_enrollment_id: ids }).order(created_at: :desc).first.try(:properties)
            properties = properties[format_field_value] if properties.present?
          else
            properties = ClientEnrollmentTracking.joins(:tracking).where(trackings: { name: fields.third }, client_enrollment_trackings: { client_enrollment_id: ids }).properties_by(format_field_value)
          end
        elsif fields.first == 'programexitdate'
          ids = object.client_enrollments.inactive.ids
          if data == 'recent'
            properties = date_format(LeaveProgram.joins(:program_stream).where(program_streams: { name: fields.second }, leave_programs: { client_enrollment_id: ids }).order(exit_date: :desc).first.try(:exit_date))
          else
            properties = date_filter(LeaveProgram.joins(:program_stream).where(program_streams: { name: fields.second }, leave_programs: { client_enrollment_id: ids }), fields.join('_')).map{|date| date_format(date.exit_date) }
          end
        elsif fields.first == 'exitprogram'
          ids = object.client_enrollments.inactive.ids
          if data == 'recent'
            properties = LeaveProgram.joins(:program_stream).where(program_streams: { name: fields.second }, leave_programs: { client_enrollment_id: ids }).order(exit_date: :desc).first.try(:properties)
            properties = properties[format_field_value] if properties.present?
          else
            properties = LeaveProgram.joins(:program_stream).where(program_streams: { name: fields.second }, leave_programs: { client_enrollment_id: ids }).properties_by(format_field_value)
          end
        end
        if fields.first == 'enrollmentdate' || fields.first == 'programexitdate'
          render partial: 'clients/form_builder_dynamic/list_date_program_stream', locals: { properties:  properties, klass: fields.join('_').split(' ').first }
        else
          properties = properties.present? ? properties : []
          render partial: 'clients/form_builder_dynamic/properties_value', locals: { properties: properties.is_a?(Array) && properties.flatten.all?{|value| DateTime.strptime(value, '%Y-%m-%d') rescue nil } ?  properties.map{|value| date_format(value.to_date) } : properties }
        end
      end
    end
  end

  dynamic do
    column(:manage, html: true, class: 'text-center', header: -> { I18n.t('datagrid.columns.clients.manage') }) do |object|
      render partial: 'clients/actions', locals: { object: object }
    end
    column(:changelog, html: true, class: 'text-center', header: -> { I18n.t('datagrid.columns.clients.changelogs') }) do |object|
      link_to t('datagrid.columns.clients.view'), client_version_path(object)
    end
  end
end
