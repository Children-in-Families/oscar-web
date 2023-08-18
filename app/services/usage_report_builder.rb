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
    data ={
      total: clients_this_month.count,
      adult_female: clients_this_month.count(&:adult_female?),
      adult_male: clients_this_month.count(&:adult_male?),
      child_female: clients_this_month.count(&:child_female?),
      child_male: clients_this_month.count(&:child_male?),
      total_with_disability: clients_has_disability_this_month.count,
      adult_female_with_disability: clients_has_disability_this_month.count(&:adult_female?),
      adult_male_with_disability: clients_has_disability_this_month.count(&:adult_male?),
      child_female_with_disability: clients_has_disability_this_month.count(&:child_female?),
      child_male_with_disability: clients_has_disability_this_month.count(&:child_female?),
      provinces: []
    }

    data[:adult_female_without_disability] = data[:adult_female] - data[:adult_female_with_disability]
    data[:adult_male_without_disability]   = data[:adult_male] - data[:adult_male_with_disability]
    data[:child_female_without_disability] = data[:child_female] - data[:child_female_with_disability]
    data[:child_male_without_disability]    = data[:child_male] - data[:child_male_with_disability]
    
    data
  end

  def cross_referral_to_primero_cases
    data ={
      total: clients_this_month.count,
      adult_female: clients_this_month.count(&:adult_female?),
      adult_male: clients_this_month.count(&:adult_male?),
      child_female: clients_this_month.count(&:child_female?),
      child_male: clients_this_month.count(&:child_male?),
      total_with_disability: clients_has_disability_this_month.count,
      adult_female_with_disability: clients_has_disability_this_month.count(&:adult_female?),
      adult_male_with_disability: clients_has_disability_this_month.count(&:adult_male?),
      child_female_with_disability: clients_has_disability_this_month.count(&:child_female?),
      child_male_with_disability: clients_has_disability_this_month.count(&:child_female?),
      provinces: []
    }

    data[:adult_female_without_disability] = data[:adult_female] - data[:adult_female_with_disability]
    data[:adult_male_without_disability]   = data[:adult_male] - data[:adult_male_with_disability]
    data[:child_female_without_disability] = data[:child_female] - data[:child_female_with_disability]
    data[:child_male_without_disability]    = data[:child_male] - data[:child_male_with_disability]
    data
  end

  def cross_referral_cases
    data ={
      total: clients_this_month.count,
      adult_female: clients_this_month.count(&:adult_female?),
      adult_male: clients_this_month.count(&:adult_male?),
      child_female: clients_this_month.count(&:child_female?),
      child_male: clients_this_month.count(&:child_male?),
      total_with_disability: clients_has_disability_this_month.count,
      adult_female_with_disability: clients_has_disability_this_month.count(&:adult_female?),
      adult_male_with_disability: clients_has_disability_this_month.count(&:adult_male?),
      child_female_with_disability: clients_has_disability_this_month.count(&:child_female?),
      child_male_with_disability: clients_has_disability_this_month.count(&:child_female?),
      agencies: []
    }

    data[:adult_female_without_disability] = data[:adult_female] - data[:adult_female_with_disability]
    data[:adult_male_without_disability]   = data[:adult_male] - data[:adult_male_with_disability]
    data[:child_female_without_disability] = data[:child_female] - data[:child_female_with_disability]
    data[:child_male_without_disability]    = data[:child_male] - data[:child_male_with_disability]
    data
  end

  def synced_cases
    data ={
      signed_up_date: nil,
      current_sharing: nil,
      total: clients_this_month.count,
      adult_female: clients_this_month.count(&:adult_female?),
      adult_male: clients_this_month.count(&:adult_male?),
      child_female: clients_this_month.count(&:child_female?),
      child_male: clients_this_month.count(&:child_male?),
      total_with_disability: clients_has_disability_this_month.count,
      adult_female_with_disability: clients_has_disability_this_month.count(&:adult_female?),
      adult_male_with_disability: clients_has_disability_this_month.count(&:adult_male?),
      child_female_with_disability: clients_has_disability_this_month.count(&:child_female?),
      child_male_with_disability: clients_has_disability_this_month.count(&:child_female?)
    }

    data[:adult_female_without_disability] = data[:adult_female] - data[:adult_female_with_disability]
    data[:adult_male_without_disability]   = data[:adult_male] - data[:adult_male_with_disability]
    data[:child_female_without_disability] = data[:child_female] - data[:child_female_with_disability]
    data[:child_male_without_disability]    = data[:child_male] - data[:child_male_with_disability]
    data[:other] = data[:total] - data[:adult_female] - data[:adult_male] - data[:child_male] - data[:child_female]

    data
  end

  def added_cases
    data ={
      total: clients_this_month.count,
      adult_female: clients_this_month.count(&:adult_female?),
      adult_male: clients_this_month.count(&:adult_male?),
      child_female: clients_this_month.count(&:child_female?),
      child_male: clients_this_month.count(&:child_male?),
      total_with_disability: clients_has_disability_this_month.count,
      adult_female_with_disability: clients_has_disability_this_month.count(&:adult_female?),
      adult_male_with_disability: clients_has_disability_this_month.count(&:adult_male?),
      child_female_with_disability: clients_has_disability_this_month.count(&:child_female?),
      child_male_with_disability: clients_has_disability_this_month.count(&:child_female?)
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

  def clients_has_disability_this_month
    @clients_has_disability_this_month ||= Client.reportable.joins(:risk_assessment).where(risk_assessments: { has_disability: true }).where(clients: { created_at: date_range }).to_a
  end

  def clients_this_month
    @clients_this_month ||= Client.reportable.where(created_at: date_range).to_a
  end
end
