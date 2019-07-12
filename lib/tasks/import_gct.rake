namespace :gct do
  desc 'Import GCT org'
  task import: :environment do
    org = Organization.create_and_build_tanent(short_name: 'gct', full_name: "GENESIS COMMUNITY OF TRANSFORMATION", logo: File.open(Rails.root.join('app/assets/images/gct_logo.png')))
    Organization.switch_to org.short_name
    Rake::Task['basic_data:import'].invoke
  end
end
