namespace :cfi do
  desc 'Import all CFI clients and related data'
  task import: :environment do
    org = Organization.create_and_build_tanent(short_name: 'cfi', full_name: "Children's Future International", logo: File.open(Rails.root.join('app/assets/images/cfi.png')))
    Organization.switch_to org.short_name

    import     = CfiImporter::Import.new('families')
    import.families

    import     = CfiImporter::Import.new('users')
    import.users

    # import     = CfiImporter::Import.new('clients')
    # import.clients
  end
end
