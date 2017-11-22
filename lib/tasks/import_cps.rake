namespace :cps do
  desc "Import all Campasio clients and related data"
  task import: :environment do
    Organization.create_and_build_tanent(short_name: 'cps', full_name: 'Compasio', logo: File.open(Rails.root.join('app/assets/images/compasio.png')))
    Organization.switch_to 'cps'

    import = CpsImporter::Import.new('Provinces')
    import.provinces

    import = CpsImporter::Import.new('Case Workers')
    import.users

    import = CpsImporter::Import.new('Donors')
    import.donors

    import = CpsImporter::Import.new('Families')
    import.families

    import = CpsImporter::Import.new('Clients')
    import.clients
  end
end
