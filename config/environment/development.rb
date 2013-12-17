Goodbrews::Application.configure do
  Mail.defaults do
    delivery_method :file, location: Crepe.root.join('tmp', 'mail')
  end

  config.mail.raise_delivery_errors = false
end
