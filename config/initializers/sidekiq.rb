Sidekiq::Extensions.enable_delay!
Sidekiq.default_worker_options = { backtrace: true }

Sidekiq.configure_server do |config|
  config.redis = { url: (ENV["REDIS_URL"] || 'redis://localhost:6379/1') }
end

Sidekiq.configure_client do |config|
  config.redis = { url: (ENV["REDIS_URL"] || 'redis://localhost:6379/1') }
end
