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

    Organization.switch_to(organization.short_name) do
      report = UsageReport.find_or_initialize_by(month: month, year: year, organization: organization)

      if report.new_record? || update
        report.assign_attributes(
          added_cases: {
            total: clients_this_month.size,
            adult_female: client_this_month.count(&:adule_female?),
            adult_male: client_this_month.count(&:adule_male?),
            adult_female_with_disability: client_has_disability_this_month.count(&:adule_female?),
            adult_male_with_disability: client_has_disability_this_month.count(&:adule_male?),
            child_female: client_this_month.count(&:child_female?),
            child_male: client_this_month.count(&:child_male?),
            child_female_with_disability: client_has_disability_this_month.count(&:child_female?),
            child_male_with_disability: client_has_disability_this_month.count(&:child_female?)
          },
          synced_cases: {

          },
          cross_referral_cases: {
            
          },
          cross_referral_to_primero_cases: {

          },
          cross_referral_from_primero_cases: {

          }
        )

        report.save!
      else
        report
      end
    end

    private

    def date_range
      @date_range ||= Date.new(year, month, 1)..Date.new(year, month, 1).end_of_month
    end

    def client_has_disability_this_month
      @client_has_disability_this_month ||= Client.with_deleted.joins(:risk_assessment).where(risk_assessments: { has_disability: true }).where(deleted_at: date_range).to_a
    end

    def clients_this_month
      @clients_this_month ||= Client.with_deleted.where(created_at: date_range).to_a
    end
  end
end
