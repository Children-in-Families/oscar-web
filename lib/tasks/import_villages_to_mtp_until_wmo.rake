namespace :import_villages_to_mtp_until_wmo do
  desc 'Import all communes and villages to mtp until wmo'
  task start: :environment do
    ngos = ["mtp", "cfi", "fsi", "ahc", "scc", "cwd", "wmo"]
    Rake::Task['communes_and_villages:start'].invoke(ngos)
    Rake::Task['communes_and_villages:start'].reenable
  end
end
