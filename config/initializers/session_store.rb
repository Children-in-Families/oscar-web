# Be sure to restart your server when you modify this file.

# Rails.application.config.session_store :cookie_store, key: '_cif-web_session'
# Rails.application.config.session_store :active_record_store, key: "_cif-web_session-#{Rails.env}"
Rails.application.config.session_store :redis_session_store, {
  key: "_cif-web_session-#{Rails.env}",
  redis: {
    expire_after: 120.minutes,  # cookie expiration
    ttl: 120.minutes,           # Redis expiration, defaults to 'expire_after'
    key_prefix: 'myapp:session:',
    url: "#{ENV['REDIS_URL']}/0",
  }
}
