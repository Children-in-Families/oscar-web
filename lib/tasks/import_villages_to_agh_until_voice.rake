namespace :import_villages_to_agh_until_voice do
  desc 'Import all communes and villages to agh until voice'
  task start: :environment do
    ngos = ["agh", "my", "ssc", "mrs", "rok", "myan", "voice"]
    Rake::Task['communes_and_villages:start'].invoke(ngos)
    Rake::Task['communes_and_villages:start'].reenable
  end
end
