if Rails.env.staging? || Rails.env.production?
  Airbrake.configure do |config|
    config.host = 'http://errbit.rotati.com'
    config.project_id = true
    config.project_key = ENV['AIRBRAKE_API_KEY']
    config.environment = Rails.env
  end

  Airbrake.add_filter do |notice|
    if notice[:errors].any? { |error| error[:type] == 'ActiveRecord::RecordNotFound' || error[:type] =='ActionController::RoutingError' }
      notice.ignore!
    end
  end
end