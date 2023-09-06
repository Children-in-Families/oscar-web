desc 'Migrate data from text to jsonb for versions table'
task migrate_paper_trail_data: :environment do
  Organization.pluck(:short_name).each_with_index do |short_name, index|
    OrganizationVersionWorker.perform_in((5*index).minutes, short_name)
  end
end
