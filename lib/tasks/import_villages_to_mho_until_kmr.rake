namespace :import_villages_to_mho_until_kmr do
  desc 'Import all communes and villages to mho until kmr'
  task start: :environment do
    ngos = ["mho", "cccu", "auscam", "isf", "shk", "fco", "kmr", "fts", "holt"]
    Rake::Task['communes_and_villages:start'].invoke(ngos)
    Rake::Task['communes_and_villages:start'].reenable
  end
end
