web: bundle exec puma
worker: bundle exec sidekiq -C config/sidekiq.yml >> log/sidekiq.log 2>&1
