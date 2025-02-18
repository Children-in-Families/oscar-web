class ClientGrid < BaseGrid
  extend ActionView::Helpers::TextHelper
  include ClientsHelper
  include ApplicationHelper
  include FormBuilderHelper
  include AssessmentHelper

  attr_accessor :current_user, :qType, :dynamic_columns, :param_data, :assessment_setting_id, :params, :enter_ngo_count
  COUNTRY_LANG = { 'cambodia' => '(Khmer)', 'thailand' => '(Thai)', 'myanmar' => '(Burmese)', 'lesotho' => '(Sesotho)', 'uganda' => '(Swahili)' }

  scope do
    Client.includes(:village, :commune, :district, :province, :family_member)
  end

  %w(given_name family_name local_given_name local_family_name).each do |field_name|
    filter(field_name, :string, header: -> { I18n.t("datagrid.columns.clients.#{field_name}") }) do |value, scope|
      filter_shared_fileds(field_name, value, scope)
    end
  end

  filter(:gender, :enum, select: :gender_list, header: -> { I18n.t('datagrid.columns.clients.gender') }) do |value, scope|
    current_org = Organization.current
    Organization.switch_to 'shared'
    slugs = SharedClient.where(gender: value.downcase).pluck(:slug)
    Organization.switch_to current_org.short_name
    scope.where(slug: slugs)
  end

  def gender_list
    [Client::GENDER_OPTIONS.map { |value| I18n.t("default_client_fields.gender_list.#{value.gsub('other', 'other_gender')}") }, Client::GENDER_OPTIONS].transpose
  end

  filter(:created_at, :date, range: true, header: -> { I18n.t('datagrid.columns.clients.created_at') })

  def self.filter_shared_fileds(field, value, scope)
    current_org = Organization.current
    Organization.switch_to 'shared'
    slugs = SharedClient.where("shared_clients.#{field} ILIKE ? OR shared_clients.local_#{field} ILIKE ?", "%#{value.squish}%", "%#{value.squish}%").pluck(:slug)
    Organization.switch_to current_org.short_name
    scope.where(slug: slugs)
  end

  filter(:slug, :string, header: -> { I18n.t('datagrid.columns.clients.id') }) { |value, scope| scope.slug_like(value) }

  filter(:code, :integer, header: -> { custom_id_translation('custom_id1') }) { |value, scope| scope.start_with_code(value) }

  filter(:kid_id, :string, header: -> { custom_id_translation('custom_id2') })

  filter(:status, :enum, select: :status_options, header: -> { I18n.t('datagrid.columns.clients.status') })

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

  filter(:initial_referral_date, :date, range: true, header: -> { I18n.t('datagrid.columns.clients.initial_referral_date') })

  filter(:received_by_id, :enum, select: :is_received_by_options, header: -> { I18n.t('datagrid.columns.clients.received_by') })

  filter(:referred_to, :enum, select: :referral_to_options, header: -> { I18n.t('datagrid.columns.clients.referred_to') })

  filter(:referred_from, :enum, select: :referral_from_options, header: -> { I18n.t('datagrid.columns.clients.referred_from') })

  filter(:referred_in, header: -> { I18n.t('datagrid.columns.clients.referred_in') })

  filter(:referred_out, header: -> { I18n.t('datagrid.columns.clients.referred_out') })

  def referral_to_options
    orgs = Organization.oscar.map { |org| { org.short_name => org.full_name } }
    orgs << { 'external referral' => "I don't see the NGO I'm looking for" }
  end

  def referral_from_options
    Organization.oscar.map { |org| { org.short_name => org.full_name } }
  end

  def is_received_by_options
    current_user.present? ? Client.joins(:case_worker_clients).where(case_worker_clients: { user_id: current_user.id }).is_received_by : Client.is_received_by
  end

  filter(:referral_source_id, :enum, select: :referral_source_options, header: -> { I18n.t('datagrid.columns.clients.referral_source') })
  filter(:referral_source_category_id, :enum, select: :referral_source_category_options, header: -> { I18n.t('datagrid.columns.clients.referral_source_category') })

  def referral_source_options
    current_user.present? ? Client.joins(:case_worker_clients).where(case_worker_clients: { user_id: current_user.id }).referral_source_is : Client.referral_source_is
  end

  def referral_source_category_options
    return [] if Client.count.zero?
    if I18n.locale == :km
      ReferralSource.where(id: Client.pluck(:referral_source_category_id).compact).pluck(:name, :id)
    else
      ReferralSource.where(id: Client.pluck(:referral_source_category_id).compact).pluck(:name_en, :id)
    end
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

  filter(:user_id, :enum, multiple: true, select: :case_worker_options, header: -> { I18n.t('datagrid.columns.clients.case_worker') }) do |ids, scope|
    ids = ids.map { |id| id.to_i }
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
    User.cach_has_clients_case_worker_options
  end

  filter(:donor_name, :enum, select: :donor_select_options, header: -> { I18n.t('datagrid.columns.clients.donor') })

  filter(:arrival_at, :datetime, header: -> { I18n.t('clients.form.arrival_at') })
  filter(:flight_nb, :string, header: -> { I18n.t('clients.form.flight_nb') })

  filter(:ratanak_achievement_program_staff_client_ids, :enum, multiple: true, select: :case_worker_options, header: -> { I18n.t('clients.form.ratanak_achievement_program_staff_client_ids') }) do |ids, scope|
    ids = ids.map { |id| id.to_i }

    if user_ids ||= User.where(id: ids).ids
      client_ids = Client.joins(:ratanak_achievement_program_staff_clients).where(users: { id: user_ids }).ids.uniq
      scope.where(id: client_ids)
    else
      scope.joins(:ratanak_achievement_program_staff_clients).where(users: { id: nil })
    end
  end

  def mosavy_official_select_options
    MoSavyOfficial.all.map { |mosavy_official| { mosavy_official.id.to_s => mosavy_official.name } }
  end

  filter(:mo_savy_officials, :enum, select: :mosavy_official_select_options, header: -> { I18n.t('clients.form.mosavy_official') })

  def donor_select_options
    Donor.has_clients.map { |donor| [donor.name, donor.id] }
  end

  def quantitative_type_options
    QuantitativeType.all.map { |t| [t.name, t.id] }
  end

  filter(:quantitative_types, :enum, select: :quantitative_type_options, header: -> { I18n.t('datagrid.columns.clients.quantitative_types') }) do |value, scope|
    ids = Client.joins(:quantitative_cases).where(quantitative_cases: { quantitative_type_id: value.to_i }).pluck(:id).uniq
    scope.where(id: ids)
  end

  def quantitative_cases
    qType.present? ? QuantitativeType.find(qType.to_i).quantitative_cases.map { |t| [t.value, t.id] } : QuantitativeCase.all.map { |t| [t.value, t.id] }
  end

  filter(:quantitative_data, :enum, select: :quantitative_cases, header: -> { I18n.t('datagrid.columns.clients.quantitative_case_values') }) do |value, scope|
    ids = Client.joins(:quantitative_cases).where(quantitative_cases: { id: value.to_i }).pluck(:id).uniq
    scope.where(id: ids)
  end

  filter(:assessments_due_to, :enum, select: Assessment::DUE_STATES, header: -> { I18n.t('datagrid.columns.clients.assessments_due_to') }) do |value, scope|
    ids = []
    setting = Setting.first
    if value == Assessment::DUE_STATES[0]
      Client.active_accepted_status.each do |client|
        next if !client.eligible_default_csi? && !(client.assessments.customs.present?)
        if setting.enable_default_assessment? && setting.enable_custom_assessment?
          ids << client.id if client.next_assessment_date == Date.today || client.custom_next_assessment_date == Date.today
        elsif setting.enable_default_assessment?
          ids << client.id if client.next_assessment_date == Date.today
        elsif setting.enable_custom_assessment?
          custom_assessment_setting_ids = client.assessments.customs.map { |ca| ca.domains.pluck(:custom_assessment_setting_id) }.flatten.uniq
          CustomAssessmentSetting.where(id: custom_assessment_setting_ids).each do |custom_assessment_setting|
            ids << client.id if client.custom_next_assessment_date(nil, custom_assessment_setting.id) == Date.today
          end
        end
      end
    else
      Client.joins(:assessments).active_accepted_status.each do |client|
        next if !client.eligible_default_csi? && !(client.assessments.customs.present?)
        custom_assessment_setting_ids = client.assessments.customs.map { |ca| ca.domains.pluck(:custom_assessment_setting_id) }.flatten.uniq
        if setting.enable_default_assessment? && setting.enable_custom_assessment?
          if client.next_assessment_date < Date.today
            ids << client.id
          else
            CustomAssessmentSetting.where(id: custom_assessment_setting_ids).each do |custom_assessment_setting|
              ids << client.id if client.custom_next_assessment_date(nil, custom_assessment_setting.id) < Date.today
            end
          end
        elsif setting.enable_default_assessment?
          ids << client.id if client.next_assessment_date < Date.today
        elsif setting.enable_custom_assessment?
          CustomAssessmentSetting.where(id: custom_assessment_setting_ids).each do |custom_assessment_setting|
            ids << client.id if client.custom_next_assessment_date(nil, custom_assessment_setting.id) < Date.today
          end
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
    Client.cached_client_assessment_domains(value, domain_id, scope)
  end

  def self.get_domain(name)
    domain = Domain.cache_find_by_name(name)
    domain.present? ? Array.new([[domain.name, domain.id]]) : []
  end

  filter(:domain_1a, :dynamic, select: proc { get_domain('1A') }, header: -> { "#{I18n.t('datagrid.columns.clients.domain')} 1A (Food Security)" }) do |(domain_id, operation, value), scope|
    value = value.to_i
    client_by_domain(operation, value, domain_id, scope)
  end

  filter(:domain_1b, :dynamic, select: proc { get_domain('1B') }, header: -> { "#{I18n.t('datagrid.columns.clients.domain')} 1B (Nutrition and Growth)" }) do |(domain_id, operation, value), scope|
    value = value.to_i
    client_by_domain(operation, value, domain_id, scope)
  end

  filter(:date_of_referral, :date, range: true, header: -> { I18n.t('datagrid.columns.clients.date_of_referral') })

  filter(:domain_2a, :dynamic, select: proc { get_domain('2A') }, header: -> { "#{I18n.t('datagrid.columns.clients.domain')} 2A (Shelter)" }) do |(domain_id, operation, value), scope|
    value = value.to_i
    client_by_domain(operation, value, domain_id, scope)
  end

  filter(:domain_2b, :dynamic, select: proc { get_domain('2B') }, header: -> { "#{I18n.t('datagrid.columns.clients.domain')} 2B (Care)" }) do |(domain_id, operation, value), scope|
    value = value.to_i
    client_by_domain(operation, value, domain_id, scope)
  end

  filter(:domain_3a, :dynamic, select: proc { get_domain('3A') }, header: -> { "#{I18n.t('datagrid.columns.clients.domain')} 3A (Protection from Abuse and Exploitation)" }) do |(domain_id, operation, value), scope|
    value = value.to_i
    client_by_domain(operation, value, domain_id, scope)
  end

  filter(:domain_3b, :dynamic, select: proc { get_domain('3B') }, header: -> { "#{I18n.t('datagrid.columns.clients.domain')} 3B (Legal Protection)" }) do |(domain_id, operation, value), scope|
    value = value.to_i
    client_by_domain(operation, value, domain_id, scope)
  end

  filter(:domain_4a, :dynamic, select: proc { get_domain('4A') }, header: -> { "#{I18n.t('datagrid.columns.clients.domain')} 4A (Wellness)" }) do |(domain_id, operation, value), scope|
    value = value.to_i
    client_by_domain(operation, value, domain_id, scope)
  end

  filter(:domain_4b, :dynamic, select: proc { get_domain('4B') }, header: -> { "#{I18n.t('datagrid.columns.clients.domain')} 4B (Health Care Services)" }) do |(domain_id, operation, value), scope|
    value = value.to_i
    client_by_domain(operation, value, domain_id, scope)
  end

  filter(:domain_5a, :dynamic, select: proc { get_domain('5A') }, header: -> { "#{I18n.t('datagrid.columns.clients.domain')} 5A (Emotional Health)" }) do |(domain_id, operation, value), scope|
    value = value.to_i
    client_by_domain(operation, value, domain_id, scope)
  end

  filter(:domain_5b, :dynamic, select: proc { get_domain('5B') }, header: -> { "#{I18n.t('datagrid.columns.clients.domain')} 5B (Social Behaviour)" }) do |(domain_id, operation, value), scope|
    value = value.to_i
    client_by_domain(operation, value, domain_id, scope)
  end

  filter(:domain_6a, :dynamic, select: proc { get_domain('6A') }, header: -> { "#{I18n.t('datagrid.columns.clients.domain')} 6A (Performance)" }) do |(domain_id, operation, value), scope|
    value = value.to_i
    client_by_domain(operation, value, domain_id, scope)
  end

  filter(:domain_6b, :dynamic, select: proc { get_domain('6B') }, header: -> { "#{I18n.t('datagrid.columns.clients.domain')} 6B (Work and Education)" }) do |(domain_id, operation, value), scope|
    value = value.to_i
    client_by_domain(operation, value, domain_id, scope)
  end

  filter(:program_streams, :enum, multiple: true, select: :program_stream_options, header: -> { I18n.t('datagrid.columns.clients.program_streams') }) do |name, scope|
    program_stream_ids = ProgramStream.name_like(name).ids
    ids = Client.joins(:client_enrollments).where(client_enrollments: { program_stream_id: program_stream_ids }).pluck(:id).uniq
    scope.where(id: ids)
  end

  def program_stream_options
    ProgramStream.joins(:client_enrollments).complete.ordered.pluck(:name).uniq
  end

  filter(:accepted_date, :date, range: true, header: -> { I18n.t('datagrid.columns.clients.ngo_accepted_date') })

  filter(:exit_date, :date, range: true, header: -> { I18n.t('datagrid.columns.clients.ngo_exit_date') })

  filter(:no_case_note, :enum, select: %w(Yes No), header: -> { I18n.t('datagrid.form.no_case_note') }) do |value, scope, grid|
    if value == 'Yes'
      scope.active_accepted_status.joins(:case_worker_clients).where(case_worker_clients: { user_id: grid.current_user.id }).joins(:case_notes).where(case_notes: { id: case_note_overdue_ids })
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

  column(:slug, order: 'clients.id', header: -> { I18n.t('datagrid.columns.clients.id') })

  column(:code, header: -> { custom_id_translation('custom_id1') }) do |object|
    object.code ||= ''
  end

  column(:kid_id, order: 'clients.kid_id', header: -> { custom_id_translation('custom_id2') })

  def self.custom_id_translation(type)
    if I18n.locale == :en || Setting.first.country_name == 'lesotho'
      if type == 'custom_id1'
        Setting.first.custom_id1_latin.present? ? Setting.first.custom_id1_latin : I18n.t('clients.other_detail.custom_id_number1')
      else
        Setting.first.custom_id2_latin.present? ? Setting.first.custom_id2_latin : I18n.t('clients.other_detail.custom_id_number2')
      end
    else
      if type == 'custom_id1'
        Setting.first.custom_id1_local.present? ? Setting.first.custom_id1_local : I18n.t('clients.other_detail.custom_id_number1')
      else
        Setting.first.custom_id2_local.present? ? Setting.first.custom_id2_local : I18n.t('clients.other_detail.custom_id_number2')
      end
    end
  end

  column(:given_name, order: 'clients.given_name', header: -> { I18n.t('datagrid.columns.clients.given_name') }, html: true) do |object|
    given_name = Client.cache_given_name(object)
    if given_name.present?
      link_to given_name, client_path(object), target: :_blank
    else
      given_name
    end
  end

  column(:given_name, header: -> { I18n.t('datagrid.columns.clients.given_name') }, html: false) do |object|
    Client.cache_given_name_export(object)
  end

  column(:family_name, order: 'clients.family_name', header: -> { I18n.t('datagrid.columns.clients.family_name') }) do |object|
    Client.cache_family_name(object)
  end

  def self.dynamic_local_name
    country = Setting.first.country_name
    I18n.locale.to_s == 'en' ? COUNTRY_LANG[country] : ''
  end

  column(:local_given_name, order: 'clients.local_given_name', header: -> { "#{I18n.t('datagrid.columns.clients.local_given_name')} #{dynamic_local_name}" }, html: true) do |object|
    Client.cache_local_given_name(object)
  end

  column(:local_given_name, order: 'clients.local_given_name', header: -> { "#{I18n.t('datagrid.columns.clients.local_given_name')} #{dynamic_local_name}" }, html: false) do |object|
    Client.cache_local_given_name(object)
  end

  column(:local_family_name, order: 'clients.local_family_name', header: -> { "#{I18n.t('datagrid.columns.clients.local_family_name')} #{dynamic_local_name}" }) do |object|
    Client.cache_local_family_name(object)
  end

  column(:gender, header: -> { I18n.t('datagrid.columns.clients.gender') }) do |object|
    Client.cache_gender(object)
  end

  column(:status, header: -> { I18n.t('datagrid.columns.clients.status') }) do |object|
    format(object.status) do |value|
      status_style(value)
    end
  end

  def client_hotline_fields
    Client::HOTLINE_FIELDS
  end

  dynamic do
    yes_no = { true: 'Yes', false: 'No' }
    content_headers = %w(concern_province_id concern_district_id concern_commune_id concern_village_id concern_street concern_house concern_address concern_address_type client_phone concern_phone_owner concern_email concern_email_owner concern_same_as_client location_description)
    client_hotline_fields.each do |hotline_field|
      value = ''
      header_text = content_headers.include?(hotline_field) ? "Concern #{I18n.t("datagrid.columns.clients.#{hotline_field}")}" : I18n.t("datagrid.columns.clients.#{hotline_field}")
      column(hotline_field.to_sym, order: false, header: -> { header_text }, class: 'client-hotline-field') do |object|
        if hotline_field[/concern_province_id|concern_district_id|concern_commune_id|concern_village_id/i]
          address_name = hotline_field.gsub('_id', '')
          value = object.send(address_name.to_sym).try(:name)
        elsif hotline_field[/protection_concern_id|necessity_id/]
          association_name = hotline_field.gsub('_id', '')
          klass_name = association_name.pluralize.to_sym
          value = object.send(klass_name).distinct.map(&:content).join(', ')
        else
          value = object.send(hotline_field.to_sym)
          value = hotline_field == 'address_type' ? value.titleize : value
          value = (value == true || value == false) ? yes_no[value.to_s.to_sym] : value.try(:titleize)
        end
        value
      end
    end
  end

  dynamic do
    quantitative_type_readable_ids = current_user.quantitative_type_permissions.readable.pluck(:quantitative_type_id) unless current_user.nil?

    QuantitativeType.cach_free_text_fields_by_visible_on('client').each do |qqt_free_text|
      if current_user.nil? || quantitative_type_readable_ids.include?(qqt_free_text.id)
        column(qqt_free_text.name.to_sym, class: 'quantitative-type', header: -> { qqt_free_text.name }, html: true) do |object|
          object.client_quantitative_free_text_cases.where('quantitative_type_id = ?', qqt_free_text.id).pluck(:content).join(', ')
        end
      end
    end
  end

  dynamic do
    quantitative_type_readable_ids = current_user.quantitative_type_permissions.readable.pluck(:quantitative_type_id) unless current_user.nil?
    quantitative_types = QuantitativeType.cached_quantitative_cases
    quantitative_types.each do |quantitative_type|
      if current_user.nil? || quantitative_type_readable_ids.include?(quantitative_type.id)
        column(quantitative_type.name.to_sym, class: 'quantitative-type', header: -> { quantitative_type.name }, html: true) do |object|
          quantitative_type_values = object.quantitative_cases.where(quantitative_type_id: quantitative_type.id).pluck(:value)
          rule = get_rule(params, quantitative_type.name.squish)
          if rule.presence && rule.dig(:type) == 'date'
            quantitative_type_values = date_condition_filter(rule, quantitative_type_values)
          elsif rule.present?
            if rule.dig(:input) == 'select'
              quantitative_type_values = select_condition_filter(rule, quantitative_type_values.flatten).presence || quantitative_type_values
            else
              quantitative_type_values = string_condition_filter(rule, quantitative_type_values.flatten).presence || quantitative_type_values
            end
          end
          quantitative_type_values.join(', ')
        end
      end
    end
  end

  dynamic do
    (CustomData.first && CustomData.first.fields || []).each do |field|
      next unless field['name']

      column(field['name'].to_sym, class: 'custom-data', header: -> { field['label'] }) do |object|
        values = object.client_custom_data && object.client_custom_data.properties[field['name']]
        values.is_a?(Array) ? values.join(', ') : values
      end
    end
  end

  date_column(:follow_up_date, html: true, header: -> { I18n.t('datagrid.columns.clients.follow_up_date') })

  column(:follow_up_date, html: false, header: -> { I18n.t('datagrid.columns.clients.follow_up_date') }) do |object|
    object.follow_up_date.present? ? object.follow_up_date : ''
  end

  column(:program_streams, html: true, order: false, header: -> { I18n.t('datagrid.columns.clients.program_streams') }) do |object, a, b, c|
    client_enrollments = program_stream_name(object.client_enrollments.active, 'active_program_stream')
    render partial: 'clients/active_client_enrollments', locals: { active_programs: client_enrollments }
  end

  column(:type_of_service, html: true, order: false, header: -> { I18n.t('datagrid.columns.clients.type_of_service') }) do |object|
    services = map_type_of_services(object)
    render partial: 'clients/type_of_services', locals: { type_of_services: services }
  end

  def call_fields
    Call::FIELDS
  end

  dynamic do
    yes_no = { true: 'Yes', false: 'No' }
    call_fields.each do |call_field|
      column(call_field.to_sym, order: false, header: -> { I18n.t("datagrid.columns.calls.#{call_field}") }, preload: :calls, class: 'call-field') do |object|
        if call_field[/date_of_call/i]
          object.calls.distinct.map { |call| call.send(call_field.to_sym) && call.send(call_field.to_sym).strftime('%d %B %Y') }.join('; ')
        elsif call_field[/start_datetime/]
          object.calls.distinct.map { |call| call.send(call_field.to_sym) && call.send(call_field.to_sym).strftime('%I:%M%p') }.join('; ')
        elsif ['called_before', 'childsafe_agent', 'answered_call', 'requested_update', 'not_a_phone_call'].include?(call_field)
          object.calls.distinct.map do |call|
            value = call.send(call_field.to_sym)
            value = value.blank? || value == false ? false : value
            value = yes_no[value.to_s.to_sym]
          end.join(', ')
        elsif call_field[/protection_concern_id|necessity_id/]
          field_name = call_field.gsub('_id', '')
          field_name = field_name.pluralize
          object.calls.map do |call|
            call.send(field_name.to_sym).pluck(:content).join(', ')
          end.join(', ')
        else
          object.calls.distinct.map { |call| call.send(call_field.to_sym) }.join(', ')
        end
      end
    end
  end

  column(:referee_name, preload: :referee, header: -> { I18n.t('datagrid.columns.clients.referee_name') }) do |object|
    object.referee&.name
  end

  column(:referee_phone, preload: :referee, header: -> { I18n.t('datagrid.columns.clients.referee_phone') }) do |object|
    object.referee&.phone
  end

  column(:referee_email, preload: :referee, header: -> { I18n.t('datagrid.columns.clients.referee_email') }) do |object|
    object.referee&.email
  end

  column(:carer_name, preload: :carer, header: -> { I18n.t('activerecord.attributes.carer.name') }) do |object|
    object.carer&.name
  end

  column(:carer_phone, preload: :carer, header: -> { I18n.t('activerecord.attributes.carer.phone') }) do |object|
    object.carer&.phone
  end

  column(:carer_email, preload: :carer, header: -> { I18n.t('activerecord.attributes.carer.email') }) do |object|
    object.carer&.email
  end

  column(:carer_relationship_to_client, preload: :carer, header: -> { I18n.t('datagrid.columns.clients.carer_relationship_to_client') }) do |object|
    object.carer&.client_relationship
  end

  column(:referee_relationship_to_client, header: -> { I18n.t('datagrid.columns.clients.referee_relationship_to_client') }) do |object|
    object.referee_relationship
  end

  column(:client_phone, header: -> { I18n.t('datagrid.columns.clients.client_phone') }) do |object|
    object.client_phone
  end

  column(:address_type, header: -> { I18n.t('datagrid.columns.clients.address_type') }) do |object|
    object.address_type && object.address_type.titleize
  end

  column(:client_email, header: -> { I18n.t('datagrid.columns.clients.client_email') }) do |object|
    object.client_email
  end

  column(:phone_owner, header: -> { I18n.t('datagrid.columns.clients.phone_owner') }) do |object|
    object.phone_owner
  end

  column(:type_of_service, html: false, order: false, header: -> { I18n.t('datagrid.columns.clients.type_of_service') }) do |object|
    services = map_type_of_services(object)
    services.map(&:name).join(', ') if services
  end

  dynamic do
    enter_ngo_count = EnterNgo.group(:client_id).count.values.max
    if enter_ngo_count > 1
      (1..enter_ngo_count).each do |ordered_number|
        column("initial_referral_date_#{ordered_number}".to_sym, header: -> { ordered_number.ordinalize + ' ' + I18n.t('datagrid.columns.clients.initial_referral_date') }) do |object|
          enter_gno = object.enter_ngos.order(:created_at)[ordered_number - 1]
          enter_gno && enter_gno.initial_referral_date.present? ? enter_gno.initial_referral_date.to_date.to_formatted_s : ''
        end

        column("received_by_id_#{ordered_number}".to_sym, preload: :received_by, order: proc { |object| object.joins(:received_by).order('users.first_name, users.last_name') }, html: true, header: -> { ordered_number.ordinalize + ' ' + I18n.t('clients.attr.received_by_id') }) do |object|
          enter_gno = object.enter_ngos.order(:created_at)[ordered_number - 1]
          render partial: 'clients/users', locals: { object: enter_gno.received_by } if enter_gno && enter_gno.received_by
        end

        column("received_by_id_#{ordered_number}".to_sym, html: false, header: -> { ordered_number.ordinalize + ' ' + I18n.t('clients.attr.received_by_id') }) do |object|
          enter_gno = object.enter_ngos.order(:created_at)[ordered_number - 1]
          enter_gno.received_by.try(:name) if enter_gno && enter_gno.received_by
        end

        column("followed_up_by_id_#{ordered_number}".to_sym, order: proc { |object| object.joins(:followed_up_by).order('users.first_name, users.last_name') }, html: true, header: -> { ordered_number.ordinalize + ' ' + I18n.t('clients.attr.followed_up_by_id') }) do |object|
          enter_gno = object.enter_ngos.order(:created_at)[ordered_number - 1]
          render partial: 'clients/users', locals: { object: enter_gno.followed_up_by } if enter_gno && enter_gno.followed_up_by
        end

        column("followed_up_by_#{ordered_number}".to_sym, html: false, header: -> { ordered_number.ordinalize + ' ' + I18n.t('clients.attr.followed_up_by_id') }) do |object|
          enter_gno = object.enter_ngos.order(:created_at)[ordered_number - 1]
          enter_gno.followed_up_by.try(:name) if enter_gno && enter_gno.followed_up_by
        end

        column("follow_up_date_#{ordered_number}".to_sym, header: -> { ordered_number.ordinalize + ' ' + I18n.t('clients.attr.follow_up_date') }) do |object|
          enter_gno = object.enter_ngos.order(:created_at)[ordered_number - 1]
          enter_gno && enter_gno.follow_up_date ? enter_gno.follow_up_date.to_date.to_formatted_s : ''
        end
      end
    else
      column(:received_by_id, preload: :received_by, order: proc { |object| object.joins(:received_by).order('users.first_name, users.last_name') }, html: true, header: -> { I18n.t('datagrid.columns.clients.received_by') }) do |object|
        render partial: 'clients/users', locals: { object: object.received_by } if object.received_by
      end

      column(:received_by_id, html: false, header: -> { I18n.t('datagrid.columns.clients.received_by') }) do |object|
        object.received_by.try(:name)
      end

      column(:followed_up_by_id, order: proc { |object| object.joins(:followed_up_by).order('users.first_name, users.last_name') }, html: true, header: -> { I18n.t('datagrid.columns.clients.followed_up_by') }) do |object|
        render partial: 'clients/users', locals: { object: object.followed_up_by } if object.followed_up_by
      end

      column(:followed_up_by, html: false, header: -> { I18n.t('datagrid.columns.clients.followed_up_by') }) do |object|
        object.followed_up_by.try(:name)
      end
    end
  end

  column(:referred_to, preload: :referrals, order: false, header: -> { I18n.t('datagrid.columns.clients.referred_to') }) do |object|
    short_names = object.referrals.map(&:referred_to)
    org_names = Organization.cached_organization_short_names(short_names)
    if short_names.include?('external referral')
      org_names << "I don't see the NGO I'm looking for"
    elsif short_names.include?('MoSVY External System')
      org_names << 'MoSVY External System'
    end
    org_names.join(', ')
  end

  column(:referred_from, preload: :referrals, order: false, header: -> { I18n.t('datagrid.columns.clients.referred_from') }) do |object|
    short_names = object.referrals.map(&:referred_from)
    org_names = Organization.cached_organization_short_names(short_names)
    org_names << 'MoSVY External System' if short_names.include?('MoSVY External System')

    org_names.join(', ')
  end

  column(:referred_in, preload: :referrals, order: false, header: -> { I18n.t('advanced_search.fields.referred_in') }) do |object|
    object.referrals.to_a.count(&:received?)
  end

  column(:referred_out, preload: :referrals, order: false, header: -> { I18n.t('advanced_search.fields.referred_out') }) do |object|
    object.referrals.to_a.count(&:delivered?)
  end

  column(:agency, preload: :agencies, order: false, header: -> { I18n.t('datagrid.columns.clients.agencies_involved') }) do |object|
    object.agencies.map(&:name).join(', ')
  end

  column(:date_of_birth, header: -> { I18n.t('datagrid.columns.clients.date_of_birth') }) do |object|
    Apartment::Tenant.switch('shared') do
      date_of_birth = SharedClient.cached_shared_client_date_of_birth(object.slug)
      date_of_birth&.strftime('%d %B %Y')
    end
  end

  column(:age, header: -> { I18n.t('datagrid.columns.clients.age') }, order: 'clients.date_of_birth desc') do |object|
    pluralize(object.age_as_years, 'year') + ' ' + pluralize(object.age_extra_months, 'month') if object.date_of_birth.present?
  end

  date_column(:created_at, html: true, header: -> { I18n.t('datagrid.columns.clients.created_at') })

  column(:created_at, html: false, header: -> { I18n.t('datagrid.columns.clients.created_at') }) do |object|
    object.created_at.present? ? object.created_at.to_date.to_formatted_s : ''
  end

  column(:created_by, header: -> { I18n.t('datagrid.columns.clients.created_by') }) do |object|
    Client.cached_client_created_by(object)
  end

  dynamic do
    country = Setting.first.try(:country_name) || 'cambodia'
    case country
    when 'cambodia'
      column(:current_address, order: 'clients.current_address', header: -> { I18n.t('datagrid.columns.clients.current_address') })

      column(:house_number, header: -> { I18n.t('datagrid.columns.clients.house_number') })

      column(:street_number, header: -> { I18n.t('datagrid.columns.clients.street_number') })

      column(:village, html: true, order: proc { |object| Client.cached_client_village_name_kh(object) }, header: -> { I18n.t('datagrid.columns.clients.village') }) do |object|
        object.village.try(:code_format)
      end

      column(:commune, html: true, order: proc { |object| Client.cached_client_commune_name_kh(object) }, header: -> { I18n.t('datagrid.columns.clients.commune') }) do |object|
        object.commune.try(:name)
      end

      column(:district, html: true, order: proc { |object| Client.cached_client_district_name(object) }, header: -> { I18n.t('datagrid.columns.clients.district') }) do |object|
        object.district_name
      end

      column(:province_id, html: true, order: proc { |object| Client.cached_client_province_name(object) }, header: -> { I18n.t('datagrid.columns.clients.current_province') }) do |object|
        object.province_name
      end

      column(:birth_province_id, html: true, header: -> { I18n.t('datagrid.columns.clients.birth_province') }) do |object|
        Apartment::Tenant.switch('shared') do
          SharedClient.cached_shared_client_birth_province_name(object.slug)
        end
      end

      if I18n.locale == :km
        column(:village, html: false, order: proc { |object| Client.cached_client_village_name_kh(object) }, header: -> { I18n.t('datagrid.columns.clients.village_kh') }) do |object|
          object.village.try(:name_kh)
        end
        column(:commune, html: false, order: proc { |object| Client.cached_client_commune_name_kh(object) }, header: -> { I18n.t('datagrid.columns.clients.commune_kh') }) do |object|
          object.commune.try(:name_kh)
        end
        column(:district, html: false, order: proc { |object| Client.cached_client_district_name(object) }, header: -> { I18n.t('datagrid.columns.clients.district_kh') }) do |object|
          object.district.try(:name_kh)
        end

        column(:province_id, html: false, order: proc { |object| Client.cached_client_province_name(object) }, header: -> { I18n.t('datagrid.columns.clients.current_province_kh') }) do |object|
          identify_province_khmer = object.province&.name&.count '/'
          if identify_province_khmer == 1
            province = object.province.name.split('/').first
          elsif identify_province_khmer == 2
            province = object.province&.name
          end
        end

        column(:birth_province_id, html: false, header: -> { I18n.t('datagrid.columns.clients.birth_province_kh') }) do |object|
          current_org = Organization.current
          Organization.switch_to 'shared'
          birth_province = SharedClient.cached_shared_client_birth_province_name(object.slug)
          identity_birth_province = birth_province&.count '/'
          if identity_birth_province == 1
            birth_province = birth_province.split('/').first
          elsif identity_birth_province == 2
            birth_province
          end
          Organization.switch_to current_org.short_name
          birth_province
        end
      else
        column(:village, html: false, order: proc { |object| Client.cached_client_village_name_kh(object) }, header: -> { I18n.t('datagrid.columns.clients.village_en') }) do |object|
          object.village.try(:name_en)
        end

        column(:commune, html: false, order: proc { |object| Client.cached_client_commune_name_kh(object) }, header: -> { I18n.t('datagrid.columns.clients.commune_en') }) do |object|
          object.commune.try(:name_en)
        end

        column(:district, html: false, order: proc { |object| Client.cached_client_district_name(object) }, header: -> { I18n.t('datagrid.columns.clients.district_en') }) do |object|
          object.district.present? ? object.district.name.split(' / ').last : nil
        end

        column(:province_id, html: false, order: proc { |object| Client.cached_client_province_name(object) }, header: -> { I18n.t('datagrid.columns.clients.current_province_en') }) do |object|
          identify_province = object.province&.name&.count '/'
          if identify_province == 1
            province = object.province.name.split('/').last
          elsif identify_province == 2
            province = object.province&.name
          end
        end

        column(:birth_province_id, html: false, header: -> { I18n.t('datagrid.columns.clients.birth_province_en') }) do |object|
          current_org = Organization.current
          Organization.switch_to 'shared'
          birth_province = SharedClient.cached_shared_client_birth_province_name(object.slug)
          identity_birth_province = birth_province&.count '/'
          if identity_birth_province == 1
            birth_province = birth_province.split('/').last
          elsif identity_birth_province == 2
            birth_province
          end
          Organization.switch_to current_org.short_name
          birth_province
        end
      end
    when 'uganda'
      column(:current_address, order: 'clients.current_address', header: -> { I18n.t('datagrid.columns.clients.current_address') })

      column(:house_number, header: -> { I18n.t('datagrid.columns.clients.house_number') })

      column(:street_number, header: -> { I18n.t('datagrid.columns.clients.street_number') })

      column(:village, order: proc { |object| Client.cached_client_village_name_kh(object) }, header: -> { I18n.t('datagrid.columns.clients.village') }) do |object|
        object.village.try(:code_format)
      end

      column(:commune, order: proc { |object| Client.cached_client_commune_name_kh(object) }, header: -> { I18n.t('datagrid.columns.clients.commune') }) do |object|
        object.commune.try(:name)
      end

      column(:district, order: proc { |object| Client.cached_client_district_name(object) }, header: -> { I18n.t('datagrid.columns.clients.district') }) do |object|
        object.district_name
      end

      column(:province, order: proc { |object| Client.cached_client_province_name(object) }, header: -> { I18n.t('datagrid.columns.clients.current_province') }) do |object|
        object.province_name
      end

      column(:birth_province, header: -> { I18n.t('datagrid.columns.clients.birth_province') }) do |object|
        current_org = Organization.current
        Organization.switch_to 'shared'
        birth_province = SharedClient.cached_shared_client_birth_province_name(object.slug)
        Organization.switch_to current_org.short_name
        birth_province
      end
    when 'thailand'
      column(:plot, header: -> { I18n.t('datagrid.columns.clients.plot') })

      column(:road, header: -> { I18n.t('datagrid.columns.clients.road') })

      column(:postal_code, header: -> { I18n.t('datagrid.columns.clients.postal_code') })

      column(:district, order: proc { |object| Client.cached_client_district_name(object) }, header: -> { I18n.t('datagrid.columns.clients.district') }) do |object|
        object.district_name
      end

      column(:subdistrict, order: 'subdistrict.name', header: -> { I18n.t('datagrid.columns.clients.subdistrict') }) do |object|
        object.subdistrict_name
      end

      column(:province, order: proc { |object| Client.cached_client_province_name(object) }, header: -> { I18n.t('datagrid.columns.clients.current_province') }) do |object|
        object.province_name
      end

      column(:birth_province, header: -> { I18n.t('datagrid.columns.clients.birth_province') }) do |object|
        current_org = Organization.current
        Organization.switch_to 'shared'
        birth_province = SharedClient.cached_shared_client_birth_province_name(object.slug)
        Organization.switch_to current_org.short_name
        birth_province
      end
    when 'lesotho'
      column(:suburb, header: -> { I18n.t('datagrid.columns.clients.suburb') })

      column(:description_house_landmark, header: -> { I18n.t('datagrid.columns.clients.description_house_landmark') })

      column(:directions, header: -> { I18n.t('datagrid.columns.clients.directions') })
    when 'myanmar'
      column(:street_line1, header: -> { I18n.t('datagrid.columns.clients.street_line1') })

      column(:street_line2, header: -> { I18n.t('datagrid.columns.clients.street_line2') })

      column(:township, order: 'township.name', header: -> { I18n.t('datagrid.columns.clients.township') }) do |object|
        object.township_name
      end

      column(:state, order: 'state.name', header: -> { I18n.t('datagrid.columns.clients.state') }) do |object|
        object.state_name
      end
    end
  end

  column(:school_name, header: -> { I18n.t('datagrid.columns.clients.school_name') })

  column(:school_grade, header: -> { I18n.t('datagrid.columns.clients.school_grade') })

  column(:has_been_in_orphanage, header: -> { I18n.t('datagrid.columns.clients.has_been_in_orphanage') }) do |object|
    object.has_been_in_orphanage.nil? ? '' : object.has_been_in_orphanage? ? 'Yes' : 'No'
  end

  column(:has_disability, class: 'text-center', header: -> { I18n.t('risk_assessments._attr.has_disability') }) do |object|
    object.has_disability.nil? ? '' : format(object.has_disability ? 'Yes' : 'No')
  end

  column(:disability_specification, header: -> { I18n.t('risk_assessments._attr.if_yes') })

  column(:has_been_in_government_care, header: -> { I18n.t('datagrid.columns.clients.has_been_in_government_care') }) do |object|
    object.has_been_in_government_care.nil? ? '' : object.has_been_in_government_care? ? 'Yes' : 'No'
  end

  date_column(:initial_referral_date, html: true, header: -> { I18n.t('datagrid.columns.clients.initial_referral_date') })

  column(:initial_referral_date, html: false, header: -> { I18n.t('datagrid.columns.clients.initial_referral_date') }) do |object|
    object.initial_referral_date.present? ? object.initial_referral_date.to_date.to_formatted_s : ''
  end

  column(:relevant_referral_information, header: -> { I18n.t('datagrid.columns.clients.relevant_referral_information') })

  column(:referral_source_id, preload: :referral_source, order: proc { |object| Client.cached_client_referral_source_name(object) }, header: -> { I18n.t('datagrid.columns.clients.referral_source') }) do |object|
    object.referral_source&.name
  end

  column(:referral_source_category_id, order: proc { |object| Client.cached_client_referral_source_name(object) }, header: -> { I18n.t('datagrid.columns.clients.referral_source_category') }) do |object|
    if I18n.locale == :km
      ReferralSource.cached_referral_source_try_name(object.referral_source_category_id)
    else
      ReferralSource.cached_referral_source_try_name_en(object.referral_source_category_id)
    end
  end

  column(:accepted_date, preload: :enter_ngos, order: false, header: -> { I18n.t('datagrid.columns.clients.ngo_accepted_date') }, html: true) do |object|
    enter_ngos = object.enter_ngos.sort_by(&:created_at).reverse
    render partial: 'clients/accepted_dates', locals: { enter_ngos: enter_ngos }
  end

  column(:exit_date, preload: :exit_ngos, order: false, header: -> { I18n.t('datagrid.columns.clients.ngo_exit_date') }, html: true) do |object|
    exit_ngos = object.exit_ngos.sort_by(&:created_at).reverse
    render partial: 'clients/exit_dates', locals: { exit_ngos: exit_ngos, client: object }
  end

  column(:rejected_note, header: -> { I18n.t('datagrid.columns.clients.rejected_note') })

  column(:exit_circumstance, preload: :exit_ngos, order: false, html: true, header: -> { I18n.t('datagrid.columns.clients.exit_circumstance') }) do |object|
    exit_ngos = object.exit_ngos.sort_by(&:created_at).reverse
    render partial: 'clients/exit_circumstances', locals: { exit_ngos: exit_ngos, client: object }
  end

  column(:exit_reasons, preload: :exit_ngos, order: false, html: true, header: -> { I18n.t('datagrid.columns.clients.exit_reasons') }) do |object|
    exit_ngos = object.exit_ngos.sort_by(&:created_at).reverse
    render partial: 'clients/exit_reasons', locals: { exit_ngos: exit_ngos, client: object }
  end

  column(:other_info_of_exit, preload: :exit_ngos, order: false, html: true, header: -> { I18n.t('datagrid.columns.clients.other_info_of_exit') }) do |object|
    exit_ngos = object.exit_ngos.sort_by(&:created_at).reverse
    render partial: 'clients/other_info_of_exits', locals: { exit_ngos: exit_ngos, client: object }
  end

  column(:exit_note, preload: :exit_ngos, order: false, html: true, header: -> { I18n.t('datagrid.columns.clients.exit_note') }) do |object|
    exit_ngos = object.exit_ngos.sort_by(&:created_at).reverse
    render partial: 'clients/exit_notes', locals: { exit_ngos: exit_ngos, client: object }
  end

  column(:what3words, header: -> { I18n.t('datagrid.columns.clients.what3words') }) do |object|
    object.what3words
  end

  column(:main_school_contact, header: -> { I18n.t('datagrid.columns.clients.main_school_contact') }) do |object|
    object.main_school_contact
  end

  column(:rated_for_id_poor, header: -> { I18n.t('datagrid.columns.clients.rated_for_id_poor') }) do |object|
    object.rated_for_id_poor
  end

  column(:user_id, preload: :users, order: false, header: -> { I18n.t('datagrid.columns.clients.case_worker') }) do |object|
    object.users.uniq.map { |case_worker| "#{case_worker.first_name} #{case_worker.last_name}".squish }.join(', ')
  end

  column(:donor_name, preload: :donors, order: false, header: -> { I18n.t('datagrid.columns.clients.donor') }) do |object|
    object.donors.uniq.map(&:name).join(', ')
  end

  column(:arrival_at, header: -> { I18n.t('clients.form.arrival_at') }) do |object|
    object.arrival_at&.strftime('%Y-%m-%d %H:%M')
  end

  column(:flight_nb, order: false, header: -> { I18n.t('clients.form.flight_nb') })
  column(:ratanak_achievement_program_staff_client_ids, order: false, header: -> { I18n.t('clients.form.ratanak_achievement_program_staff_client_ids') }) do |object|
    object.ratanak_achievement_program_staff_clients.distinct.map { |case_worker| "#{case_worker.first_name} #{case_worker.last_name}".squish }.join(', ')
  end

  column(:mo_savy_officials, order: false, header: -> { I18n.t('clients.form.mosavy_official') }) do |object|
    object.mo_savy_officials.map { |mo_savy_official| "#{mo_savy_official.name} #{mo_savy_official.position}".squish }.join(', ')
  end

  column(:family_id, preload: :family, order: false, header: -> { I18n.t('advanced_search.fields.family_id') }) do |object|
    object.family&.id
  end

  column(:family, preload: :family, order: false, header: -> { I18n.t('datagrid.columns.clients.placements.family') }) do |object|
    object.family&.name
  end

  column(:family_type, preload: :family, order: false, header: -> { I18n.t('datagrid.columns.families.family_type') }) do |object|
    object.family&.family_type
  end

  column(:case_note_created_at, header: -> { I18n.t('datagrid.columns.case_note_created_at') }, html: true) do |object|
    render partial: 'clients/case_note_created_date', locals: { object: object }
  end

  column(:case_note_date, header: -> { I18n.t('datagrid.columns.clients.case_note_date') }, html: true) do |object|
    render partial: 'clients/case_note_date', locals: { object: object }
  end

  column(:case_note_type, header: -> { I18n.t('datagrid.columns.clients.case_note_type') }, html: true) do |object|
    render partial: 'clients/case_note_type', locals: { object: object }
  end

  column(:assessment_created_at, preload: :assessments, header: -> { I18n.t('datagrid.columns.clients.assessment_created_at', assessment: I18n.t('clients.show.assessment')) }, html: true) do |object|
    render partial: 'clients/assessments', locals: { object: object.assessments.defaults.order(:created_at), assessment_field_name: nil }
  end

  column(:date_of_assessments, preload: :assessments, header: -> { I18n.t('datagrid.columns.clients.date_of_assessments', assessment: I18n.t('clients.show.assessment')) }, html: true) do |object|
    render partial: 'clients/assessments', locals: { object: object.assessments.defaults.order(:assessment_date), assessment_field_name: 'assessment_date' }
  end

  column(:completed_date, preload: :assessments, header: -> { I18n.t('datagrid.columns.clients.assessment_completed_date', assessment: I18n.t('clients.show.assessment')) }, html: true) do |object|
    if $param_rules
      basic_rules = $param_rules['basic_rules']
      basic_rules = basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
      results = mapping_assessment_query_rules(basic_rules).reject(&:blank?)
      assessment_completed_sql, assessment_number = assessment_filter_values(results)
      sql = '(assessments.completed = true)'.squish
      if assessment_number.present? && assessment_completed_sql.present?
        assessments = Client.cached_client_assessment_number_completed_date(object, sql, assessment_number)
      elsif assessment_completed_sql.present?
        sql = assessment_completed_sql[/assessments\.completed_date.*/]
        assessments = Client.cached_client_sql_assessment_completed_date(object, sql)
      else
        rule = basic_rules['rules'].select { |h| h['id'] == 'date_of_assessments' }.first
        if rule.present?
          date_of_assessments_query = date_of_assessments_query_string(rule[:id], rule['field'], rule['operator'], rule['value'])
          assessments = object.assessments.defaults.where(date_of_assessments_query)
        else
          assessments = object.assessments.defaults
        end
        assessments = Client.cached_client_sql_assessment_completed_date(object, sql)
      end
    else
      assessments = Client.cached_client_assessment_order_completed_date(object)
    end
    render partial: 'clients/completed_assessments', locals: { object: assessments }
  end

  column(:date_of_referral, header: -> { I18n.t('datagrid.columns.clients.date_of_referral') }, html: true) do |object|
    render partial: 'clients/referral', locals: { object: object }
  end

  column(:custom_assessment_created_at, preload: :assessments, header: -> { I18n.t('datagrid.columns.clients.custom_assessment_created_at', assessment: I18n.t('clients.show.assessment')) }, html: true) do |object|
    render partial: 'clients/assessments', locals: { object: object.assessments.customs.order(:created_at), assessment_field_name: nil }
  end

  column(:date_of_custom_assessments, preload: :assessments, header: -> { I18n.t('datagrid.columns.clients.date_of_custom_assessments', assessment: I18n.t('clients.show.assessment')) }, html: true) do |object|
    render partial: 'clients/assessments', locals: { object: object.assessments.customs.order(:assessment_date), assessment_field_name: 'assessment_date' }
  end

  column(:custom_assessment, preload: :assessments, header: -> { I18n.t('datagrid.columns.clients.custom_assessment', assessment: I18n.t('clients.show.assessment')) }) do |object|
    custom_assessment_names = object.assessments.customs.joins(domains: :custom_assessment_setting).order(:created_at).distinct.pluck('custom_assessment_settings.custom_assessment_name', 'assessments.created_at')
    custom_assessment_names = custom_assessment_names.map { |custom_assessment_name, assessment_date| "#{custom_assessment_name} (#{assessment_date.strftime('%d %B %Y')})" }
    format(custom_assessment_names.join(', ')) do |values|
      unorderred_list(values.split(', '))
    end
  end

  column(:custom_completed_date, preload: :assessments, header: -> { I18n.t('datagrid.columns.clients.assessment_custom_completed_date', assessment: I18n.t('clients.show.assessment')) }, html: true) do |object|
    if $param_rules
      basic_rules = $param_rules['basic_rules']
      basic_rules = basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
      results = mapping_assessment_query_rules(basic_rules).reject(&:blank?)
      assessment_completed_sql, assessment_number = assessment_filter_values(results)
      sql = '(assessments.completed = true)'.squish
      if assessment_number.present? && assessment_completed_sql.present?
        assessments = Client.cached_client_assessment_custom_number_completed_date(object, sql, assessment_number)
      elsif assessment_completed_sql.present?
        sql = assessment_completed_sql[/assessments\.completed_date.*/]
        assessments = Client.cached_client_sql_assessment_custom_completed_date(object, sql)
      else
        rule = basic_rules['rules'].select { |h| h['id'] == 'date_of_assessments' }.first
        if rule.present?
          date_of_assessments_query = date_of_assessments_query_string(rule[:id], rule['field'], rule['operator'], rule['value'])
          assessments = object.assessments.customs.where(date_of_assessments_query)
        else
          assessments = object.assessments.customs
        end
        assessments = Client.cached_client_sql_assessment_custom_completed_date(object, sql)
      end
    else
      assessments = Client.cached_client_assessment_custom_order_completed_date(object)
    end
    render partial: 'clients/completed_assessments', locals: { object: assessments }
  end

  column(:care_plan_date, header: -> { I18n.t('care_plans.care_plan_date') }, html: true) do |object|
    render partial: 'shared/care_plans/care_plan_date', locals: { object: object.care_plans }
  end

  column(:care_plan_completed_date, header: -> { I18n.t('datagrid.columns.clients.care_plan_completed_date') }, html: true) do |object|
    render partial: 'shared/care_plans/care_plans', locals: { object: object.care_plans }
  end

  column(:care_plan_count, header: -> { I18n.t('datagrid.columns.clients.care_plan_count') }, html: true, class: 'hide') do |object|
  end

  column(:time_in_ngo, header: -> { I18n.t('datagrid.columns.clients.time_in_ngo') }) do |object|
    if object.time_in_ngo.present?
      time_in_ngo = object.time_in_ngo
      years = I18n.t('clients.show.time_in_care_around.year', count: time_in_ngo[:years]) if time_in_ngo[:years] > 0
      months = I18n.t('clients.show.time_in_care_around.month', count: time_in_ngo[:months]) if time_in_ngo[:months] > 0
      days = I18n.t('clients.show.time_in_care_around.day', count: time_in_ngo[:days]) if time_in_ngo[:days] > 0
      [years, months, days].join(' ')
    end
  end

  column(:time_in_cps, header: -> { I18n.t('datagrid.columns.clients.time_in_cps') }) do |object|
    cps_lists = []
    if object.time_in_cps.present?
      time_in_cps = object.time_in_cps
      time_in_cps.each do |cps|
        unless cps[1].blank?
          years = I18n.t('clients.show.time_in_care_around.year', count: cps[1][:years]) if (cps[1][:years].present? && cps[1][:years] > 0)
          months = I18n.t('clients.show.time_in_care_around.month', count: cps[1][:months]) if (cps[1][:months].present? && cps[1][:months] > 0)
          days = I18n.t('clients.show.time_in_care_around.day', count: cps[1][:days]) if (cps[1][:days].present? && cps[1][:days] > 0)
          time_in_cps = [years, months, days].join(' ')
          cps_lists << [cps[0], time_in_cps].join(': ')
        end
      end
    end
    cps_lists.join(', ')
  end

  column(:indirect_beneficiaries, header: -> { I18n.t('datagrid.columns.clients.indirect_beneficiaries') }) do |object|
    object.indirect_beneficiaries
  end

  dynamic do
    legal_doc_fields.each do |legal_doc_field|
      column(legal_doc_field.to_sym, header: -> { I18n.t("clients.show.#{legal_doc_field}") }, class: 'legal-document-header') do |object|
        object.public_send(legal_doc_field) ? 'Yes' : 'No'
      end
    end
  end

  dynamic do
    if CaseNotes::CustomField.first
      cn_custom_field = CaseNotes::CustomField.first
      cn_custom_field.data_fields.each do |field|
        column_name = "case_note_custom_field_#{field['label'].parameterize.underscore}"
        column(column_name.to_sym, header: -> { field['label'] }, html: true) do |object|
          render partial: 'clients/case_note_custom_field', locals: { object: object, custom_field: cn_custom_field, field: field }
        end
      end
    end
  end

  dynamic do
    if enable_default_assessment?
      column(:all_csi_assessments, preload: :assessments, header: -> { I18n.t('datagrid.columns.clients.all_csi_assessments', assessment: I18n.t('clients.show.assessment')) }, html: true) do |object|
        render partial: 'clients/all_csi_assessments', locals: { object: object.assessments.defaults }
      end

      Domain.cache_order_by_identity.select(&:client_csi?).each do |domain|
        domain_id = domain.id
        identity = domain.identity
        column(domain.convert_identity.to_sym, class: 'domain-scores', header: identity, html: true) do |client|
          assessments = map_assessment_and_score(client, identity, domain_id)
          assessment_domains = assessments.map { |assessment| assessment.assessment_domains.joins(:domain).where(domains: { identity: identity }) }.flatten.uniq
          render partial: 'clients/list_domain_score', locals: { assessment_domains: assessment_domains }
        end
      end
    end

    if enable_custom_assessment?
      column(:all_custom_csi_assessments, preload: :assessments, header: -> { I18n.t('datagrid.columns.clients.all_custom_csi_assessments') }, html: true) do |object|
        render partial: 'clients/all_csi_assessments', locals: { object: object.assessments.customs }
      end
      Domain.custom_csi_domains.order_by_identity.each do |domain|
        identity = domain.identity
        column("custom_#{domain.convert_identity}".to_sym, class: 'domain-scores', header: identity, html: true) do |client|
          assessments = map_assessment_and_score(client, identity, domain.id)
          assessment_domains = assessments.customs.map { |assessment| assessment.assessment_domains.joins(:domain).where(domains: { identity: identity }) }.flatten.uniq
          render partial: 'clients/list_domain_score', locals: { assessment_domains: assessment_domains }
        end
      end
    end
  end

  dynamic do
    next unless dynamic_columns.present?
    data = param_data.presence
    dynamic_columns.each do |column_builder|
      fields = column_builder[:id].gsub('&qoute;', '"').split('__')
      column(column_builder[:id].to_sym, class: 'form-builder', header: -> { form_builder_format_header(fields) }, html: true) do |object|
        format_field_value = fields.last.gsub("'", "''").gsub('&qoute;', '"').gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
        if fields.first == 'formbuilder'
          if data == 'recent'
            if fields.last == 'Has This Form'
              properties = object.custom_field_properties.cached_client_custom_field_properties_count(object, fields.second)
            else
              properties = object.custom_field_properties.cached_client_custom_field_properties_order(object, fields.second)
              properties = properties[format_field_value] if properties.present?
            end
          else
            if fields.last == 'Has This Form'
              properties = [custom_form_with_has_form(object, fields).count]
            else
              if $param_rules
                custom_field_id = object.custom_fields.cached_client_custom_field_find_by(object, fields.second)
                basic_rules = $param_rules.present? && $param_rules[:basic_rules] ? $param_rules[:basic_rules] : $param_rules
                basic_rules = basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
                results = mapping_form_builder_param_value(basic_rules, 'formbuilder')
                query_string = get_query_string(results, 'formbuilder', 'custom_field_properties.properties')
                sql = query_string.reverse.reject(&:blank?).map { |sql| "(#{sql})" }.join(' AND ')

                properties = object.custom_field_properties.cached_client_custom_field_properties_properties_by(object, custom_field_id, sql, format_field_value)
                properties = properties.blank? ? custom_form_with_has_form(object, fields).properties_by(format_field_value) : properties
              else
                properties = form_builder_query(object.custom_field_properties, fields.second, column_builder[:id].gsub('&qoute;', '"'), 'custom_field_properties.properties').properties_by(format_field_value)
              end
            end
          end
        elsif fields.first == 'enrollmentdate'
          if data == 'recent'
            properties = date_format(object.client_enrollments.cached_client_order_enrollment_date(object, fields.second))
          else
            properties = date_filter(object.client_enrollments.cached_client_enrollment_date_join(object, fields.second), fields.join('__')).map { |date| date_format(date.enrollment_date) }
          end
        elsif fields.first == 'enrollment'
          if data == 'recent'
            properties = object.client_enrollments.cached_client_order_enrollment_date_properties(object, fields.second)
            properties = properties[format_field_value] if properties.present?
          else
            properties = object.client_enrollments.cached_client_enrollment_date_join(object, fields.second).properties_by(format_field_value)
          end
        elsif fields.first == 'tracking'
          ids = object.client_enrollments.ids
          if data == 'recent'
            properties = ClientEnrollmentTracking.cached_tracking_order_created_at(object, fields.third, ids)
            properties = properties[format_field_value] if properties.present?
          else
            client_enrollment_trackings = ClientEnrollmentTracking.cached_client_enrollment_tracking(object, fields.third, ids)
            properties = form_builder_query(client_enrollment_trackings, fields.first, column_builder[:id].gsub('&qoute;', '"')).properties_by(format_field_value, client_enrollment_trackings)
          end
        elsif fields.first == 'exitprogramdate'
          ids = object.client_enrollments.inactive.ids
          if data == 'recent'
            properties = date_format(LeaveProgram.cached_program_exit_date(fields.second, ids))
          else
            properties = date_filter(LeaveProgram.cached_program_stream_leave(fields.second, ids), fields.join('__')).map { |date| date_format(date.exit_date) }
          end
        elsif fields.first == 'exitprogram'
          ids = object.client_enrollments.inactive.ids
          if data == 'recent'
            properties = LeaveProgram.joins(:program_stream).where(program_streams: { name: fields.second }, leave_programs: { client_enrollment_id: ids }).order(exit_date: :desc).first.try(:properties)
            properties = properties[format_field_value] if properties.present?
          else
            if $param_rules.nil?
              properties = LeaveProgram.joins(:program_stream).where(program_streams: { name: fields.second }, leave_programs: { client_enrollment_id: ids }).properties_by(format_field_value)
            else
              basic_rules = $param_rules['basic_rules']
              basic_rules = basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
              results = mapping_exit_program_date_param_value(basic_rules)
              query_string = get_exit_program_date_query_string(results)
              properties = LeaveProgram.joins(:program_stream).where(program_streams: { name: fields.second }, leave_programs: { client_enrollment_id: ids }).where(query_string).properties_by(format_field_value)
            end
          end
        end

        properties = property_filter(properties, fields.last)
        if fields.first == 'enrollmentdate' || fields.first == 'exitprogramdate'
          render partial: 'clients/form_builder_dynamic/list_date_program_stream', locals: { properties: properties, klass: fields.join('__').split(' ').first }
        else
          properties = properties.present? ? properties : []
          render partial: 'clients/form_builder_dynamic/properties_value', locals: { properties: properties.is_a?(Array) && properties.flatten.all? { |value| DateTime.strptime(value, '%Y-%m-%d') rescue nil } ? properties.map { |value| date_format(value.to_date) } : properties }
        end
      end
    end
  end

  column(:level_of_risk, preload: [:risk_assessment, :assessments], class: 'text-center', html: true, header: -> { I18n.t('risk_assessments._attr.level_of_risk') }) do |object|
    risk_assessment = object.risk_assessment
    assessments = [risk_assessment, *object.assessments.select(&:client_risk_assessment?)]
    render partial: 'clients/level_of_risk_list', locals: { assessments: assessments.compact }
  end

  column(:date_of_risk_assessment, preload: [:risk_assessment, :assessments], class: 'text-center', html: true, header: -> { I18n.t('risk_assessments._attr.assessment_date') }) do |object|
    risk_assessment = object.risk_assessment
    assessments = [risk_assessment, *object.assessments.select(&:client_risk_assessment?)]
    render partial: 'clients/risk_assessment_list', locals: { assessments: assessments.compact }
  end

  column(:has_hiv_or_aid, preload: :risk_assessment, class: 'text-center', header: -> { I18n.t('risk_assessments._attr.has_hiv_or_aid') }) do |object|
    risk_assessment = object.risk_assessment
    format(risk_assessment&.has_hiv_or_aid ? 'Yes' : 'No')
  end

  column(:has_known_chronic_disease, preload: :risk_assessment, class: 'text-center', header: -> { I18n.t('risk_assessments._attr.has_known_chronic_disease') }) do |object|
    risk_assessment = object.risk_assessment
    format(risk_assessment&.has_known_chronic_disease ? 'Yes' : 'No')
  end

  dynamic do
    column(:manage, html: true, class: 'text-center', header: -> { I18n.t('datagrid.columns.clients.manage') }) do |object|
      render partial: 'clients/actions', locals: { object: object }
    end

    column(:changelog, html: true, class: 'text-center', header: -> { I18n.t('datagrid.columns.clients.changelogs') }) do |object|
      link_to t('datagrid.columns.clients.view'), client_version_path(object)
    end
  end

  def custom_form_with_has_form(object, fields)
    [object.custom_field_properties.joins(:custom_field).where(custom_fields: { form_title: fields.second, entity_type: 'Client' }).count]
  end

  def custom_assessment_setting
    @custom_assessment_setting ||= CustomAssessmentSetting.find_by(id: assessment_setting_id)
  end
end
