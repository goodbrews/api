Mail.defaults do
  delivery_method :file, location: Crepe.root.join('tmp', 'mail')
end

# Log database queries to STDOUT
ActiveRecord::Base.logger = Crepe.logger
