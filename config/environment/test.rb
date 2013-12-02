Goodbrews::Application.configure do
  Mail.defaults do
    delivery_method :test
  end
end
