desc 'Migrate data from text to jsonb for versions table'
task migrate_paper_trail_data: :environment do
  Organization.pluck(:short_name).each do |short_name|
    Organization.switch_to short_name

    PaperTrail::Version.ids.each do |version_id|
      VersionWorker.perform_async(version_id, short_name)
    end
  end
end
