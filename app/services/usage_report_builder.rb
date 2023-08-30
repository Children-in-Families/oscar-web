class UsageReportBuilder < ServiceBase
  attr_reader :organization
  attr_reader :month
  attr_reader :year
  attr_reader :update

  def initialize(organization, month, year, update = false)
    @organization = organization
    @month = month
    @year = year
    @update = update
  end

  def call
    puts "Building usage report for #{organization.short_name} for #{month}/#{year}"

    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month
    report = UsageReport.find_or_initialize_by(month: month, year: year, organization: organization)

    Apartment::Tenant.switch(organization.short_name) do
      if report.new_record? || update
        report.assign_attributes(
          added_cases: added_cases,
          synced_cases: synced_cases,
          cross_referral_cases: cross_referral_cases,
          cross_referral_to_primero_cases: cross_referral_to_primero_cases,
          cross_referral_from_primero_cases: cross_referral_from_primero_cases
        )

        report.save!
      end
    end
    
    report
  end
  
  private

  def cross_referral_from_primero_cases
    data = {
      total: clients_from_primero.count,
      adult_female: clients_from_primero.count(&:adult_female?),
      adult_male: clients_from_primero.count(&:adult_male?),
      child_female: clients_from_primero.count(&:child_female?),
      child_male: clients_from_primero.count(&:child_male?),
      total_with_disability: clients_has_disability_from_primero.count,
      adult_female_with_disability: clients_has_disability_from_primero.count(&:adult_female?),
      adult_male_with_disability: clients_has_disability_from_primero.count(&:adult_male?),
      child_female_with_disability: clients_has_disability_from_primero.count(&:child_female?),
      child_male_with_disability: clients_has_disability_from_primero.count(&:child_female?),
      provinces: Province.joins(:clients).where(clients: { id: clients_from_primero.map(&:id) }).uniq.pluck(:name).compact
    }

    data[:adult_female_without_disability] = data[:adult_female] - data[:adult_female_with_disability]
    data[:adult_male_without_disability]   = data[:adult_male] - data[:adult_male_with_disability]
    data[:child_female_without_disability] = data[:child_female] - data[:child_female_with_disability]
    data[:child_male_without_disability]    = data[:child_male] - data[:child_male_with_disability]
    data[:other] = data[:total] - data[:adult_female] - data[:adult_male] - data[:child_male] - data[:child_female]
    
    data
  end

  def clients_has_disability_from_primero
    @clients_has_disability_from_primero ||= Client.joins(:risk_assessment).where(risk_assessments: { has_disability: true }, clients: { id: clients_from_primero.map(&:id) }).to_a.uniq
  end

  def clients_from_primero
    @clients_from_primero ||= Client.reportable.joins(:referrals).where(referrals: { created_at: date_range, referred_from: 'MoSVY External System' }).to_a.uniq
  end

  def cross_referral_to_primero_cases
    data = {
      total: clients_to_primero.count,
      adult_female: clients_to_primero.count(&:adult_female?),
      adult_male: clients_to_primero.count(&:adult_male?),
      child_female: clients_to_primero.count(&:child_female?),
      child_male: clients_to_primero.count(&:child_male?),
      total_with_disability: clients_has_disability_to_primero.count,
      adult_female_with_disability: clients_has_disability_to_primero.count(&:adult_female?),
      adult_male_with_disability: clients_has_disability_to_primero.count(&:adult_male?),
      child_female_with_disability: clients_has_disability_to_primero.count(&:child_female?),
      child_male_with_disability: clients_has_disability_to_primero.count(&:child_female?),
      provinces: Province.joins(:clients).where(clients: { id: clients_to_primero.map(&:id) }).uniq.pluck(:name).compact
    }

    data[:adult_female_without_disability] = data[:adult_female] - data[:adult_female_with_disability]
    data[:adult_male_without_disability]   = data[:adult_male] - data[:adult_male_with_disability]
    data[:child_female_without_disability] = data[:child_female] - data[:child_female_with_disability]
    data[:child_male_without_disability]    = data[:child_male] - data[:child_male_with_disability]
    data[:other] = data[:total] - data[:adult_female] - data[:adult_male] - data[:child_male] - data[:child_female]

    data
  end

  def clients_has_disability_to_primero
    @clients_has_disability_to_primero ||= Client.joins(:risk_assessment).where(risk_assessments: { has_disability: true }, clients: { id: clients_to_primero.map(&:id) }).to_a.uniq
  end

  def clients_to_primero
    @clients_to_primero ||= Client.reportable.joins(:referrals).where(referrals: { created_at: date_range, referred_to: 'MoSVY External System' }).to_a.uniq
  end

  def cross_referral_cases
    data = {
      total: cross_referral_clients.count,
      adult_female: cross_referral_clients.count(&:adult_female?),
      adult_male: cross_referral_clients.count(&:adult_male?),
      child_female: cross_referral_clients.count(&:child_female?),
      child_male: cross_referral_clients.count(&:child_male?),
      total_with_disability: cross_referral_clients_with_disability.count,
      adult_female_with_disability: cross_referral_clients_with_disability.count(&:adult_female?),
      adult_male_with_disability: cross_referral_clients_with_disability.count(&:adult_male?),
      child_female_with_disability: cross_referral_clients_with_disability.count(&:child_female?),
      child_male_with_disability: cross_referral_clients_with_disability.count(&:child_female?),
      agencies: cross_referral_agencies
    }

    data[:adult_female_without_disability] = data[:adult_female] - data[:adult_female_with_disability]
    data[:adult_male_without_disability]   = data[:adult_male] - data[:adult_male_with_disability]
    data[:child_female_without_disability] = data[:child_female] - data[:child_female_with_disability]
    data[:child_male_without_disability]    = data[:child_male] - data[:child_male_with_disability]
    data[:other] = data[:total] - data[:adult_female] - data[:adult_male] - data[:child_male] - data[:child_female]

    data
  end

  def cross_referral_clients_with_disability
    @cross_referral_clients_with_disability ||= Client.joins(:risk_assessment).where(risk_assessments: { has_disability: true }, clients: { id: cross_referral_clients.map(&:id) }).to_a.uniq
  end

  def cross_referral_clients
    @cross_referral_clients ||= Client.reportable.joins(:referrals).where(referrals: { created_at: date_range, referred_from: organization.short_name }).where("referred_to != ?", 'MoSVY External System').to_a.uniq
  end

  def cross_referral_agencies
    Referral.where(created_at: date_range, referred_from: organization.short_name).where("referred_to != ?", 'MoSVY External System').map { |referral| referral.ngo_name.presence || ngo_hash_mapping[referral.referred_to] }.compact
  end

  def ngo_hash_mapping
    ngos = Organization.pluck(:short_name, :full_name)
    ngos << ["MoSVY External System", "MoSVY External System"]
    ngos << ["external referral", "I don't see the NGO I'm looking for..."]
    ngos.to_h
  end

  def synced_cases
    data = {
      signed_up_date: organization.integrated_date,
      current_sharing: organization.integrated?,
      total: synced_clients.count,
      adult_female: synced_clients.count(&:adult_female?),
      adult_male: synced_clients.count(&:adult_male?),
      child_female: synced_clients.count(&:child_female?),
      child_male: synced_clients.count(&:child_male?),
      total_with_disability: synced_clients_with_disability.count,
      adult_female_with_disability: synced_clients_with_disability.count(&:adult_female?),
      adult_male_with_disability: synced_clients_with_disability.count(&:adult_male?),
      child_female_with_disability: synced_clients_with_disability.count(&:child_female?),
      child_male_with_disability: synced_clients_with_disability.count(&:child_female?)
    }

    data[:adult_female_without_disability] = data[:adult_female] - data[:adult_female_with_disability]
    data[:adult_male_without_disability]   = data[:adult_male] - data[:adult_male_with_disability]
    data[:child_female_without_disability] = data[:child_female] - data[:child_female_with_disability]
    data[:child_male_without_disability]    = data[:child_male] - data[:child_male_with_disability]
    data[:other] = data[:total] - data[:adult_female] - data[:adult_male] - data[:child_male] - data[:child_female]

    data
  end

  def synced_clients_with_disability
    @synced_clients_with_disability ||= Client.joins(:risk_assessment).where(risk_assessments: { has_disability: true }, clients: { id: synced_clients.map(&:id) }).to_a.uniq
  end

  def synced_clients
    @synced_clients ||= Client.reportable.where.not(external_id: [nil, '']).where(created_at: date_range).to_a
  end

  def added_cases
    data = {
      total: clients.count,
      adult_female: clients.count(&:adult_female?),
      adult_male: clients.count(&:adult_male?),
      child_female: clients.count(&:child_female?),
      child_male: clients.count(&:child_male?),
      total_with_disability: clients_has_disability.count,
      adult_female_with_disability: clients_has_disability.count(&:adult_female?),
      adult_male_with_disability: clients_has_disability.count(&:adult_male?),
      child_female_with_disability: clients_has_disability.count(&:child_female?),
      child_male_with_disability: clients_has_disability.count(&:child_female?)
    }

    data[:adult_female_without_disability] = data[:adult_female] - data[:adult_female_with_disability]
    data[:adult_male_without_disability]   = data[:adult_male] - data[:adult_male_with_disability]
    data[:child_female_without_disability] = data[:child_female] - data[:child_female_with_disability]
    data[:child_male_without_disability]    = data[:child_male] - data[:child_male_with_disability]
    data[:other] = data[:total] - data[:adult_female] - data[:adult_male] - data[:child_male] - data[:child_female]
    
    data
  end

  def date_range
    @date_range ||= Date.new(year, month, 1)..Date.new(year, month, 1).end_of_month
  end

  def clients_has_disability
    @clients_has_disability ||= Client.joins(:risk_assessment).where(risk_assessments: { has_disability: true }, clients: { id: clients.map(&:id) }).to_a.uniq
  end

  def clients
    @clients ||= Client.reportable.where(created_at: date_range).to_a
  end
end
