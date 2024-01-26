class OrganizationWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'priority'

  def perform(org_id)
    organization = Organization.find(org_id)

    begin
      Apartment::Tenant.create(organization.short_name)
    rescue Apartment::TenantExists => e
      Rails.logger.info "Tenant #{organization.short_name} already exists"
      # Continue
    end

    organization.update(onboarding_status: 'seeding_default_data')

    Organization.seed_generic_data(organization.id, organization.referral_source_category_name)
    organization.update(onboarding_status: 'completed')
  end
end
