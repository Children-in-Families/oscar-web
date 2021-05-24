namespace :client_importer do
  desc "Import client"
  task :import, [:short_name] => :environment do |task, args|
    short_name = args.short_name
    Organization.switch_to short_name
    path = Rails.root.join("vendor/data/organizations/CHI-Updated-OSCaR_New_Instance_Data_Import_Template.xlsx")
    import_object = ChiHaiti::Import.new(path)
    import_object.import_all
    puts "Done!!!"
  end

end
