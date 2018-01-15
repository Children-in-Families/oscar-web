namespace :import do
  desc "Import District and Move Archive District"
  task district: :environment do
    import = MoveDistrict::Import.new
    import.districts
    import.update_district_in_client
  end
end
