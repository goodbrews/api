config    = Rails.root.join('config', 'redis.yml')
redis     = YAML.load(ERB.new(File.new(config).read).result)[Rails.env]

Sidekiq.configure_server do |config|
  config.redis = { url: "#{redis['uri']}/#{redis['db']}", namespace: 'sidekiq' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "#{redis['uri']}/#{redis['db']}", namespace: 'sidekiq' }
end
