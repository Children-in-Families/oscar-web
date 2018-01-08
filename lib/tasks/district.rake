namespace :import do
  desc "Import District and Move Archive District"
  task district: :environment do
    user_reminder = MoveDistrict::Import.new
    user_reminder.districts
    user_reminder.update_district_in_client
  end
end
