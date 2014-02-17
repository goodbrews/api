Mail.defaults do
  delivery_method :smtp, {
    address:   ENV['SMTP_ADDRESS'],
    port:      ENV['SMTP_PORT'],
    user_name: ENV['SMTP_USER_NAME'],
    password:  ENV['SMTP_PASSWORD']
  }
end

Crepe.logger = Logger.new File.open('log/production.log', 'a')
