namespace :mh do
  desc 'Import all MH users and related data'
  task import: :environment do
    mh_org = Organization.find_by(short_name: 'mh')
    Organization.switch_to mh_org.short_name

    import = MhImporter::Import.new('Case Workers')
    import.users
  end
end
