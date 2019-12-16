namespace :ngo_permission_set do
  desc "Update NGOs permission sets"
  task update: :environment do
    ngos = %w(fsc isf mtp cif mrs)

    ngos.each do |ngo_name|
      Organization.switch_to ngo_name
      path = "vendor/data/organizations/#{ngo_name}.xlsx"
      update = NgosPermission::Update.new('Worksheet1', path)
      update.users
    end
  end
end
