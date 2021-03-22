class OrganizationWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'priority'

  def perform(org)
    # Do something
    Organization.delay(queue: :priority).seed_generic_data(org.id)
  end
end
