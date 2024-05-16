class Dashboard
  include Rails.application.routes.url_helpers
  attr_reader :clients

  def initialize(clients, family_only: false)
    @families = Family.active

    unless family_only
      @clients  = clients.select(:id, :status, :user_id)
      @partners = Partner.all
      @agencies = Agency.all
      @staff    = User.all
      @referral_sources = ReferralSource.child_referrals.all
      @program_streams = ProgramStream.joins(:client_enrollments).where(client_enrollments: { status: 'Active' }).distinct
    end
  end

  def client_program_stream
    program_streams = ProgramStream.joins(:clients, :client_enrollments).group("program_streams.id, client_enrollments.status").select("program_streams.id, program_streams.name, COUNT(DISTINCT(client_enrollments.client_id)) AS client_enrollment_count").having("client_enrollments.status = 'Active'")
    program_streams.map do |p|
      url = { 'condition': 'AND', 'rules': [{ 'id': 'active_program_stream', 'field': 'active_program_stream', 'type': 'string', 'input': 'select', 'operator': 'equal', 'value': p.id }]}
      {
        name: p.name,
        y: p.client_enrollment_count,
        url: clients_path(
          'client_advanced_search': {
            action_report_builder: '#builder',
            basic_rules: url.to_json
          },
          commit: 'commit'
        )
      }
    end
  end

  def family_type_statistic
    return @family_type_statistic if @family_type_statistic.present?

    arr = []
    arr << { name: 'Long Term Foster Care', y: foster_count, url: families_path('family_grid[family_type]': 'Long Term Foster Care', 'family_grid[status]': 'Active') } if foster_count > 0
    arr << { name: "Extended Family / Kinship Care", y: kinship_count, url: families_path('family_grid[family_type]': "Extended Family / Kinship Care", 'family_grid[status]': 'Active') } if kinship_count > 0
    arr << { name: "Short Term / Emergency Foster Care", y: emergency_count, url: families_path('family_grid[family_type]': "Short Term / Emergency Foster Care", 'family_grid[status]': 'Active') } if emergency_count > 0
    arr << { name: 'Birth Family (Both Parents)', y: birth_family_both_parents_count, url: families_path('family_grid[family_type]': 'Birth Family (Both Parents)', 'family_grid[status]': 'Active') } if birth_family_both_parents_count > 0
    arr << { name: 'Birth Family (Only Mother)', y: birth_family_only_mother_count, url: families_path('family_grid[family_type]': 'Birth Family (Only Mother)', 'family_grid[status]': 'Active') } if birth_family_only_mother_count > 0
    arr << { name: 'Birth Family (Only Father)', y: birth_family_only_father_count, url: families_path('family_grid[family_type]': 'Birth Family (Only Father)', 'family_grid[status]': 'Active') } if birth_family_only_father_count > 0
    arr << { name: 'Domestically Adopted', y: domestically_adopted_count, url: families_path('family_grid[family_type]': 'Domestically Adopted', 'family_grid[status]': 'Active') } if domestically_adopted_count > 0
    arr << { name: 'Child-Headed Household', y: child_headed_household_count, url: families_path('family_grid[family_type]': 'Child-Headed Household', 'family_grid[status]': 'Active') } if child_headed_household_count > 0
    arr << { name: 'No Family', y: no_family_count, url: families_path('family_grid[family_type]': 'No Family', 'family_grid[status]': 'Active') } if no_family_count > 0
    arr << { name: 'Other', y: other_count, url: families_path('family_grid[family_type]': 'Other', 'family_grid[status]': 'Active') } if other_count > 0

    @family_type_statistic = arr
  end

  def program_stream_report_gender
    male = I18n.t('gender_list.male')
    female = I18n.t('gender_list.female')
    other = I18n.t('gender_list.other_gender')

    male_data = program_stream_report_by('male')
    female_data = program_stream_report_by('female')
    other_data = program_stream_report_by('other')

    [
      {
        name: male,
        y: male_data[:total],
        active_data: male_data[:data]
      },
      {
        name: female,
        y: female_data[:total],
        active_data: female_data[:data]
      },
      {
        name: other,
        y: other_data[:total],
        active_data: other_data[:data]
      }
    ]
  end

  def family_count
    @family_count ||= @families.size
  end

  def foster_count
    @foster_count ||= @families.foster.size
  end

  def kinship_count
    @kinship_count ||= @families.kinship.size
  end

  def emergency_count
    @emergency_count ||= @families.emergency.size
  end

  def birth_family_both_parents_count
    @birth_family_both_parents_count ||= @families.birth_family_both_parents.size
  end

  def birth_family_only_mother_count
    @birth_family_only_mother_count ||= @families.birth_family_only_mother.size
  end

  def birth_family_only_father_count
    @birth_family_only_father_count ||= @families.birth_family_only_father.size
  end

  def domestically_adopted_count
    @domestically_adopted_count ||= @families.domestically_adopted.size
  end

  def child_headed_household_count
    @child_headed_household_count ||= @families.child_headed_household.size
  end

  def no_family_count
    @no_family_count ||= @families.no_family.size
  end

  def other_count
    @other_count ||= @families.other.size
  end

  def referral_source_count
    @referral_source_count ||= @referral_sources.size
  end

  def program_stream_count
    @program_stream_count ||= @program_streams.size
  end

  private

  def program_stream_report_by(gender)
    sql_condition = gender == 'other' ? "clients.gender NOT IN ('male', 'female') AND client_enrollments.status = 'Active'" : "clients.gender = '#{gender}' AND client_enrollments.status = 'Active'"

    program_streams = ProgramStream.joins(:clients).group("program_streams.id, clients.gender, client_enrollments.status")
                                  .select("program_streams.id, program_streams.name, clients.gender AS client_gender, COUNT(DISTINCT(client_enrollments.client_id)) AS client_enrollment_count")
                                  .having(sql_condition)

    { total: program_streams.map(&:client_enrollment_count).sum, data: mapping_program_data(program_streams, gender) }
  end

  def mapping_program_data(program_streams, gender)
    @program_streams.map do |ps|
      client_enrollment_count_hash = program_streams.map{|ps| [ps.name, ps.client_enrollment_count] }.to_h
      url = { 'condition': 'AND', 'rules': [{ 'id': 'active_program_stream', 'field': 'active_program_stream', 'type': 'string', 'input': 'select', 'operator': 'equal', 'value': ps.id },
        { 'id': 'gender', 'field': 'gender', 'type': 'string', 'input': 'select', 'operator': 'equal', 'value': gender } ]}
      {
        name: ps.name,
        y: client_enrollment_count_hash[ps.name] || 0,
        url: clients_path(
          client_advanced_search: {
            action_report_builder: '#builder',
            basic_rules: url.to_json
          },
          commit: 'commit'
        )
      }
    end
  end
end
