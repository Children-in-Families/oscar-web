namespace :komar_rikreay do
  desc 'Import all Komar Rikreay clients and related data'
  task import: :environment do
    # org = Organization.create_and_build_tanent(short_name: 'krc', full_name: "Komar Rikreay Cambodia", logo: File.open(Rails.root.join('app/assets/images/komar-rikreay.jpg')))
    Organization.switch_to 'krc'

    # Rake::Task['agencies:import'].invoke
    # Rake::Task['departments:import'].invoke
    # Rake::Task['provinces:import'].invoke
    # Rake::Task['referral_sources:import'].invoke
    # Rake::Task['quantitative_types:import'].invoke
    # Rake::Task['quantitative_cases:import'].invoke
    # Rake::Task['districts:import'].invoke

    # import     = KomarRikreayImporter::Import.new('Case Workers')
    # import.users

    # import     = KomarRikreayImporter::Import.new('Donors')
    # import.donors

    # import     = KomarRikreayImporter::Import.new('Families')
    # import.families

    import     = KomarRikreayImporter::Import.new('Clients')
    import.clients

  end
end
