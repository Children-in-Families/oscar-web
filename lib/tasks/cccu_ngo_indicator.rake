namespace :cccu_country_indicator do
  desc 'Update cccu setting country, NGO country and client country origin'
  task update: :environment do
    Organization.find_by(short_name: 'cccu').update(country: 'uganda')
    Organization.switch_to 'cccu'
    Setting.first.update(country_name: 'uganda')
    Client.where('slug ilike ?', '%cccu%').update_all(country_origin: 'uganda')
    Organization.switch_to 'shared'
    SharedClient.where('slug ilike ?', '%cccu%').update_all(country_origin: 'uganda')
  end
end
