class OrganizationVersionWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(tenent)
    Organization.switch_to tenent

    PaperTrail::Version.ids.each do |version_id|
      VersionWorker.perform_async(version_id, tenent)
    end
  end
end
