namespace :clients do
  desc 'Import all clients'
  task import: :environment do
    path = Rails.root.join("vendor/data/organizations/Client_Data_Import_Template_v7_KT_25oct21.xlsx")
    Apartment::Tenant.switch 'kt'
    import     = ClientsImporter::Import.new(path, ['clients'])
    import.import_all
  end
end
