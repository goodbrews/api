# Explicitly require all workers that Sidekiq will need.
require 'app/workers/webhook_worker'

redis = YAML.load(ERB.new(File.new('config/redis.yml').read).result)[Crepe.env]

Sidekiq.configure_server do |config|
  config.redis = { url: redis['uri'], namespace: 'sidekiq' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis['uri'], namespace: 'sidekiq' }
end
