namespace :vietnam_address do
  desc 'Import vietnam addresses'
  task :import, [:short_name] => :environment do |task, args|
    short_name = args.short_name
    if short_name.present?
      Apartment::Tenant.switch short_name
      address = ImportVietnamAddress::Import.new('vendor/data/addressess/vietnam/vn_addresses.xlsx')
      address.import
    end
  end
end
