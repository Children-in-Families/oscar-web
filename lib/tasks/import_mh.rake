namespace :mhc do
  desc "Import Mother's Heart Cambodia users"
  task import: :environment do
    org = Organization.create_and_build_tanent(short_name: 'mhc', full_name: "Mother's Heart Cambodia", logo: File.open(Rails.root.join('app/assets/images/MH-Logo.png')))
    Organization.switch_to org.short_name

    import = MhcImporter::Import.new('Case Workers')
    import.users
  end
end
