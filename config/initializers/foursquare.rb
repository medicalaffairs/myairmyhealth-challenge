Rails.application.config.foursquare={
	:client_id => 'YOUR ID',
	:client_secret => 'YOUR SECRET',
	:push_secret => 'YOUR PUSH SECRET'
}
Rails.application.config.foursquare[:redirect_uri] = case Rails.env 
  when 'production' then "http://YOUR PRODUCTION URL/foursquare/callback" 
  when 'development' then "http://localhost:3000/foursquare/callback"
  when 'test' then "http://localhost:3000/foursquare/callback"
  else nil
end
