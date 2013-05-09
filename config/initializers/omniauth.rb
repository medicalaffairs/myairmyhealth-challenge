Rails.application.config.middleware.use OmniAuth::Builder do
  provider :singly, "YOUR KEY", "YOUR SECRET"   #Production
end