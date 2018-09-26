CarrierWave.configure do |config|
 config.storage = :file
 if Rails.env.staging? || Rails.env.production? || Rails.env.demo?
   config.fog_credentials = {
     provider: 'AWS',
     aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
     aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
     region: ENV['FOG_REGION']
   }
   config.storage = :fog
   config.fog_directory = ENV['FOG_DIRECTORY']
 end
end

module CarrierWave
  module MiniMagick
    def quality(percentage)
      manipulate! do |img|
        img.quality(percentage.to_s)
        img = yield(img) if block_given?
        img
      end
    end
  end
end
