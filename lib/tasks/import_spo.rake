namespace :spo do
  desc "Import all Sepheo clients and related data"
  task import: :environment do
    org = Organization.create_and_build_tanent(short_name: 'spo', full_name: "Sepheo", logo: File.open(Rails.root.join('app/assets/images/Sepheo-logo.jpg')))
    Organization.switch_to org.short_name

    Rake::Task['agencies:import'].invoke
    Rake::Task['departments:import'].invoke
    Rake::Task['provinces:import'].invoke
    Rake::Task['referral_sources:import'].invoke
    Rake::Task['quantitative_types:import'].invoke
    Rake::Task['quantitative_cases:import'].invoke

    import = SpoImporter::Import.new('case workers')
    import.users

    import = SpoImporter::Import.new('donors')
    import.donors

    import = SpoImporter::Import.new('clients')
    import.clients
  end
end
