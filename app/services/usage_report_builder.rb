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
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month
    report = UsageReport.find_or_initialize_by(month: month, year: year, organization: organization)

    Apartment::Tenant.switch(organization.short_name) do
      if report.new_record? || update
        report.assign_attributes(
          added_cases: {
            total: clients_this_month.size,
            adult_female: clients_this_month.count(&:adult_female?),
            adult_male: clients_this_month.count(&:adult_male?),
            adult_female_with_disability: clients_has_disability_this_month.count(&:adult_female?),
            adult_male_with_disability: clients_has_disability_this_month.count(&:adult_male?),
            child_female: clients_this_month.count(&:child_female?),
            child_male: clients_this_month.count(&:child_male?),
            child_female_with_disability: clients_has_disability_this_month.count(&:child_female?),
            child_male_with_disability: clients_has_disability_this_month.count(&:child_female?)
          },
          synced_cases: {
            signed_up_date: nil,
            current_sharing: nil,
            total: 0,
            adult_female: 0,
            adult_male: 0,
            adult_female_with_disability: 0,
            adult_male_with_disability: 0,
            child_female: 0,
            child_male: 0,
            child_female_with_disability: 0,
            child_male_with_disability: 0
          },
          cross_referral_cases: {
            total: 0,
            adult_female: 0,
            adult_male: 0,
            adult_female_with_disability: 0,
            adult_male_with_disability: 0,
            child_female: 0,
            child_male: 0,
            child_female_with_disability: 0,
            child_male_with_disability: 0,
            agencies: []
          },
          cross_referral_to_primero_cases: {
            total: 0,
            adult_female: 0,
            adult_male: 0,
            adult_female_with_disability: 0,
            adult_male_with_disability: 0,
            child_female: 0,
            child_male: 0,
            child_female_with_disability: 0,
            child_male_with_disability: 0,
            provinces: []
          },
          cross_referral_from_primero_cases: {
            total: 0,
            adult_female: 0,
            adult_male: 0,
            adult_female_with_disability: 0,
            adult_male_with_disability: 0,
            child_female: 0,
            child_male: 0,
            child_female_with_disability: 0,
            child_male_with_disability: 0,
            provinces: []
          }
        )

        report.save!
      end
    end
    
    report
  rescue ActiveRecord::StatementInvalid => e
    if e.message.match(/PG::UndefinedTable: ERROR:  relation "risk_assessments" does not exist/)
      puts e.message
      puts "=====================#{organization.short_name} is not properly setup. Skipping... ====================================="
    else
      raise e
    end
  end
  
  private

  def date_range
    @date_range ||= Date.new(year, month, 1)..Date.new(year, month, 1).end_of_month
  end

  def clients_has_disability_this_month
    @clients_has_disability_this_month ||= Client.with_deleted.joins(:risk_assessment).where(risk_assessments: { has_disability: true }).where(deleted_at: date_range).to_a
  end

  def clients_this_month
    @clients_this_month ||= Client.with_deleted.where(created_at: date_range).to_a
  end
end
