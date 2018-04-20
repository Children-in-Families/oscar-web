namespace :voice do
  desc 'Import all Voice clients and related data'
  task import: :environment do
    org = Organization.create_and_build_tanent(short_name: 'voice', full_name: "Voice", logo: File.open(Rails.root.join('app/assets/images/voice.jpg')))
    Organization.switch_to org.short_name

    Rake::Task['agencies:import'].invoke
    Rake::Task['departments:import'].invoke
    Rake::Task['provinces:import'].invoke
    Rake::Task['referral_sources:import'].invoke
    Rake::Task['quantitative_types:import'].invoke
    Rake::Task['quantitative_cases:import'].invoke

    import     = MoveDistrict::Import.new
    import.districts

    import     = VoiceImporter::Import.new('Users')
    import.users

    import     = VoiceImporter::Import.new('Family')
    import.families

    import     = VoiceImporter::Import.new('Client')
    import.clients
  end
end
