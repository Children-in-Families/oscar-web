namespace :tutorials_client do
  desc 'inport clients'
  task create: :environment do
    Organization.switch_to 'tutorials'
    20.times do
      client = Client.new
      client.received_by_id = User.first.id
      client.user_ids = [User.first.id]
      client.initial_referral_date = Date.today
      client.gender = ['male', 'female'].sample
      client.given_name = FFaker::Name.name 
      client.family_name = FFaker::Name.name
      client.referral_source_category_id = ReferralSource.pluck(:id).sample
      client.name_of_referee = FFaker::Name.name
      client.save
    end

  end
end
