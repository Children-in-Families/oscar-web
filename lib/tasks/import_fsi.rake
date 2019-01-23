namespace :fsi do
  desc "update new FSI user lists"
  task update: :environment do
    # org = Organization.create_and_build_tanent(short_name: 'fsi', full_name: "Friends International", logo: File.open(Rails.root.join('app/assets/images/fsi.png')))
    # Organization.switch_to org.short_name

    # Rake::Task['agencies:import'].invoke
    # Rake::Task['departments:import'].invoke
    # Rake::Task['provinces:import'].invoke
    # Rake::Task['referral_sources:import'].invoke
    # Rake::Task['quantitative_types:import'].invoke
    # Rake::Task['quantitative_cases:import'].invoke

    # import = FsiImporter::Import.new('Users')
    # import.users

    # import = FsiImporter::Import.new('Donors')
    # import.donors

    # import = FsiImporter::Import.new('Families')
    # import.families

    # import = FsiImporter::Import.new('Clients')
    # import.clients

    Organization.switch_to 'fsi'
    import = FsiImporter::Import.new('Users')
    import.update_users
  end
end
