CarrierWave.configure do |config|
 config.storage = :file
 if Rails.env.staging? || Rails.env.production? || Rails.env.demo?
   config.storage = :fog
   config.fog_credentials = {
     provider: 'AWS',
     aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
     aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
     region: ENV['FOG_REGION']
   }
   config.fog_directory = ENV['FOG_DIRECTORY']
 end
end
