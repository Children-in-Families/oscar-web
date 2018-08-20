namespace :update_compasio do
  desc 'Update slug prefix and org info'
  task update: :environment do |task, args|
    Organization.switch_to 'cps'
    Client.all.each do |client|
      client.slug = client.slug.gsub('cps', 'gca')
      client.save(validate: false)
    end

    ReferralSource.find_by(name: 'Compasio - OSCaR Referral').destroy

    puts 'Done!'

    org = Organization.current
    org.full_name  = 'Global '
    org.short_name = 'gca'
    org.save

    puts 'Done!!'
  end
end

# ALTER SCHEMA cps RENAME TO gca;

