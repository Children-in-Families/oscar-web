namespace :fcf_ngo do
  desc 'Update FCF NGO in cif cct mhc and fsc'
  task update: :environment do
    orgs = Organization.where(short_name: ['cif', 'cct', 'mhc', 'fsc', 'cfi', 'mtp'])
    orgs.map{ |org| org.update(fcf_ngo: true) }
  end
end
