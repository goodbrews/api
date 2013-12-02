redis = YAML.load(ERB.new(File.new('config/redis.yml').read).result)[Grape.env]

Recommendable.configure do |config|
  # Recommendable's connection to Redis.
  config.redis = Redis.new(
    host: redis['host'],
    port: redis['port'],
    db: redis['db']
  )

  # A prefix for all keys Recommendable uses.
  config.redis_namespace = :recommendable

  # Automatically enqueue users to have their recommendations refreshed after
  # they like or dislike an item.
  config.auto_enqueue = true

  # The number of nearest/furthest neighbors (k-NN) to check when updating
  # recommendations for a user. Set to `nil` if you want to check all
  # other users as opposed to a subset of the nearest ones.
  config.nearest_neighbors  = 100
  config.furthest_neighbors = 100

  # The number of recommendations to store for each user.
  config.recommendations_to_store = 100
end
