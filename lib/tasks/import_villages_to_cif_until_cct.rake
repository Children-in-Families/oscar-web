namespace :import_villages_to_cif_until_cct do
  desc 'Import all communes and villages to cif until cct'
  task start: :environment do
    ngos = ["cif", "newsmile", "icf", "tlc", "demo", "fsc", "cct"]
    Rake::Task['communes_and_villages:start'].invoke(ngos)
    Rake::Task['communes_and_villages:start'].reenable
  end
end
