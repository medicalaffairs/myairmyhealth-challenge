Rails.application.config.cosm={
	:client_id => 'YOUR ID',
	:client_secret => 'YOUR SECRET'
}
Rails.application.config.cosm[:redirect_uri] = case Rails.env 
  when 'production' then "http://YOUR PRODUCTION URL/cosm/callback" 
  when 'development' then "http://localhost:3000/cosm/callback"
  when 'test' then "http://localhost:3000/cosm/callback"
  else nil
end
