Goodbrews::Application.configure do
  Mail.defaults do
    delivery_method :file, location: Crepe.root.join('tmp', 'mail')
  end

  config.mail.raise_delivery_errors = false

  # Set up Rails-style autoloading for the Development environment
  relative_load_paths = %w[
    app/apis
    app/helpers
    app/models
    app/models/concerns
    app/presenters
    lib
  ]

  ActiveSupport::Dependencies.autoload_paths += relative_load_paths
end
