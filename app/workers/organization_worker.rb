class OrganizationWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'priority'

  def perform(org_id)
    # Do something
    Organization.delay(queue: :priority).seed_generic_data(org_id)
  end
end
