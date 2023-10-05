desc 'Migrate data from text to jsonb for versions table'
task migrate_paper_trail_data: :environment do
  Organization.where(onboarding_status: 'completed').pluck(:short_name).each do |short_name|
    OrganizationVersionWorker.perform_async(short_name)
  end
end
