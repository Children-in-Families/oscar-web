namespace :fcf_ngo do
  desc 'Set FCF NGOs'
  task update: :environment do
    orgs = Organization.where(short_name: ['cif', 'cct', 'mhc', 'fsc', 'cfi', 'mtp'])
    orgs.map{ |org| org.update(fcf_ngo: true) }
  end
end
