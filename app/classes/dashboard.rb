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
  end

  def client_gender_statistic
    [
      {
        name: I18n.t('classes.dashboard.males'),
        y: @clients.all_active_types.male.count,
        active_data: [
          {
            name: I18n.t('classes.dashboard.male_emergency_cares'),
            y: @clients.active_ec.male.count,
            url: clients_path("client_grid[gender]":"Male","client_grid[status]":"Active EC")
          },
          {
            name: I18n.t('classes.dashboard.male_kinship_cares'),
            y: @clients.active_kc.male.count,
            url: clients_path("client_grid[gender]":"Male","client_grid[status]":"Active KC")
          },
          {
            name: I18n.t('classes.dashboard.male_foster_cares'),
            y: @clients.active_fc.male.count,
            url: clients_path("client_grid[gender]":"Male","client_grid[status]":"Active FC")
          }
        ]
      },
      {
        name: I18n.t('classes.dashboard.females'),
        y: @clients.all_active_types.female.count,
        active_data: [
         {
           name: I18n.t('classes.dashboard.female_emergency_cares'),
           y: @clients.active_ec.female.count,
           url: clients_path("client_grid[gender]":"Female","client_grid[status]":"Active EC")
         },
         {
           name: I18n.t('classes.dashboard.female_kinship_cares'),
           y: @clients.active_kc.female.count,
           url: clients_path("client_grid[gender]":"Female","client_grid[status]":"Active KC")
         },
         {
           name: I18n.t('classes.dashboard.female_foster_cares'),
           y: @clients.active_fc.female.count,
           url: clients_path("client_grid[gender]":"Female","client_grid[status]":"Active FC")
         }
        ]
      }
    ]
  end

  def client_status_statistic
    [
      { name: I18n.t('classes.dashboard.emergency_cares_html'), y: @clients.active_ec.count, url: clients_path("client_grid[status]": 'Active EC') },
      { name: I18n.t('classes.dashboard.foster_cares_html'), y: @clients.active_fc.count, url: clients_path("client_grid[status]": 'Active FC') },
      { name: I18n.t('classes.dashboard.kinship_cares_html'), y: @clients.active_kc.count, url: clients_path("client_grid[status]": 'Active KC') }
    ]
  end

  def family_type_statistic
    [
      { name: 'Foster', y: foster_count, url: families_path("family_grid[family_type]": 'foster') },
      { name: 'Kinship', y: kinship_count, url: families_path("family_grid[family_type]": 'kinship') },
      { name: 'Emergency', y: emergency_count, url: families_path("family_grid[family_type]": 'emergency') }
    ]
  end

  def able_count
    @clients.able.count
  end

  def family_count
    @families.count
  end

  def foster_count
    @families.foster.count
  end

  def kinship_count
    @families.kinship.count
  end

  def emergency_count
    @families.emergency.count
  end

  def referral_source_count
    @referral_sources.count
  end
end
