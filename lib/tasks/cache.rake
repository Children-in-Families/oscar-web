namespace :cache do
  desc 'clear rails cache'
  task clear: :environment do
    Rails.cache.clear
  end
end
