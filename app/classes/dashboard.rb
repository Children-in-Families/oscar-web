class Dashboard
  include Rails.application.routes.url_helpers
  attr_reader :clients

  def initialize(clients)
    @clients  = clients
    @families = Family.all
    @partners = Partner.all
    @agencies = Agency.all
    @staff    = User.all
    @referral_sources = ReferralSource.all
    @program_streams = ProgramStream.joins(:client_enrollments).where(client_enrollments: { status: 'Active' }).uniq
  end

  def client_program_stream
    @program_streams.map do |p|
      url = { 'condition': 'AND', 'rules': [{ 'id': 'active_program_stream', 'field': 'active_program_stream', 'type': 'string', 'input': 'select', 'operator': 'equal', 'value': p.id }]}
      {
        name: p.name,
        y: p.client_enrollments.active.pluck(:client_id).uniq.count,
        url: clients_path('client_advanced_search[basic_rules]': url.to_json)
      }
    end
  end

  # def client_gender_statistic
  #   [
  #     {
  #       name: I18n.t('classes.dashboard.males'),
  #       y: @clients.all_active_types.male.count,
  #       active_data: [
  #         {
  #           name: I18n.t('classes.dashboard.male_emergency_cares'),
  #           y: @clients.active_ec.male.count,
  #           url: clients_path('client_grid[gender]': 'Male', 'client_grid[status]': 'Active EC')
  #         },
  #         {
  #           name: I18n.t('classes.dashboard.male_kinship_cares'),
  #           y: @clients.active_kc.male.count,
  #           url: clients_path('client_grid[gender]': 'Male', 'client_grid[status]': 'Active KC')
  #         },
  #         {
  #           name: I18n.t('classes.dashboard.male_foster_cares'),
  #           y: @clients.active_fc.male.count,
  #           url: clients_path('client_grid[gender]': 'Male', 'client_grid[status]': 'Active FC')
  #         }
  #       ]
  #     },
  #     {
  #       name: I18n.t('classes.dashboard.females'),
  #       y: @clients.all_active_types.female.count,
  #       active_data: [
  #        {
  #          name: I18n.t('classes.dashboard.female_emergency_cares'),
  #          y: @clients.active_ec.female.count,
  #          url: clients_path('client_grid[gender]': 'Female', 'client_grid[status]': 'Active EC')
  #        },
  #        {
  #          name: I18n.t('classes.dashboard.female_kinship_cares'),
  #          y: @clients.active_kc.female.count,
  #          url: clients_path('client_grid[gender]': 'Female', 'client_grid[status]': 'Active KC')
  #        },
  #        {
  #          name: I18n.t('classes.dashboard.female_foster_cares'),
  #          y: @clients.active_fc.female.count,
  #          url: clients_path('client_grid[gender]': 'Female', 'client_grid[status]': 'Active FC')
  #        }
  #       ]
  #     }
  #   ]
  # end

  # def client_status_statistic
  #   [
  #     { name: I18n.t('classes.dashboard.emergency_cares_html'), y: @clients.active_ec.count, url: clients_path('client_grid[status]': 'Active EC') },
  #     { name: I18n.t('classes.dashboard.foster_cares_html'), y: @clients.active_fc.count, url: clients_path('client_grid[status]': 'Active FC') },
  #     { name: I18n.t('classes.dashboard.kinship_cares_html'), y: @clients.active_kc.count, url: clients_path('client_grid[status]': 'Active KC') }
  #   ]
  # end

  def family_type_statistic
    [
      { name: 'Foster', y: foster_count, url: families_path('family_grid[family_type]': 'foster') },
      { name: 'Kinship', y: kinship_count, url: families_path('family_grid[family_type]': 'kinship') },
      { name: 'Emergency', y: emergency_count, url: families_path('family_grid[family_type]': 'emergency') }
    ]
  end

  def program_stream_report_gender
    active_enrollments = Client.joins(:client_enrollments).where(client_enrollments: { status: 'Active' })
    males = active_enrollments.where(clients: { gender: 'male' } ).uniq
    females = active_enrollments.where(clients: { gender: 'female' } ).uniq
    [
      {
        name: I18n.t('classes.dashboard.males'),
        y: males.size,
        active_data: program_stream_report_by(males.ids, 'Male')
      },
      {
        name: I18n.t('classes.dashboard.females'),
        y: females.size,
        active_data: program_stream_report_by(females.ids, 'Female')
      }
    ]
  end

  def able_count
    @clients.able.size
  end

  def family_count
    @families.size
  end

  def foster_count
    @families.foster.size
  end

  def kinship_count
    @families.kinship.size
  end

  def emergency_count
    @families.emergency.size
  end

    def referral_source_count
    @referral_sources.size
  end

  def program_stream_count
    @program_streams.size
  end

  private

  def program_stream_report_by(client_ids, gender)
    program_streams = @program_streams.where(client_enrollments: {client_id: client_ids})
    program_streams.map do |p|
      url = { 'condition': 'AND', 'rules': [{ 'id': 'active_program_stream', 'field': 'active_program_stream', 'type': 'string', 'input': 'select', 'operator': 'equal', 'value': p.id },
        { 'id': 'gender', 'field': 'gender', 'type': 'string', 'input': 'select', 'operator': 'equal', 'value': gender.downcase } ]}
      active_client_ids = p.client_enrollments.active.where(client_id: client_ids)
      {
        name: "#{p.name} (#{gender})",
        y: active_client_ids.size,
        url: clients_path('client_advanced_search[basic_rules]': url.to_json)
      }
    end
  end
end
