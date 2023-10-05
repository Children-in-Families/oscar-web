class VersionWorker
  include Sidekiq::Worker

  def perform(version_id, tenent)
    Organization.switch_to tenent
    
    version = PaperTrail::Version.find(version_id)
    version.object_changes  = YAML.load(version.old_object_changes) if version.old_object_changes.present?
    version.object          = YAML.load(version.old_object)         if version.old_object.present?
    version.save!
  end
end
