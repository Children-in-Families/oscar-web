namespace :thailand_sub_addresses do
  desc 'Import Thailand sub addresses'
  task import: :environment do
    Organization.thailand.each do |org|
      Apartment::Tenant.switch org.short_name
      next_id = Subdistrict.maximum(:id).to_i.next
      ActiveRecord::Base.connection.execute("alter sequence subdistricts_id_seq restart with #{next_id};")
      address = ImportThaiSubAddress::Import.new('vendor/data/addressess/thai/thai_sub_addresses.xlsx')
      address.import
    end
  end
end
