namespace :cif do
  desc 'Import all CIF task'
  task import: :environment do
    Rake::Task['users:import'].invoke
    Rake::Task['ec:import'].invoke
    Rake::Task['partners:import'].invoke
    Rake::Task['fc_families:import'].invoke
    Rake::Task['kc_families:import'].invoke
    Rake::Task['kc_managements:import'].invoke
    Rake::Task['fc_managements:import'].invoke
    Rake::Task['quarterly_reports:import'].invoke
    Rake::Task['quantitatives:import'].invoke
  end
end


