# Be sure to restart your server when you modify this file.

# Rails.application.config.session_store :cookie_store, key: '_cif-web_session'
# Rails.application.config.session_store :active_record_store, key: "_cif-web_session-#{Rails.env}"
Rails.application.config.session_store :redis_session_store, {
  key: "_cif-web_session-#{Rails.env}",
  redis: {
    key_prefix: 'CifWeb:session:',
    url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"),
  }
}
