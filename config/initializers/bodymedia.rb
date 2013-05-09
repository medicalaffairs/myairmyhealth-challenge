Rails.application.config.bodymedia={
	:key => 'YOUR KEY',
	:shared_secret => 'YOUR SECRET'
}
Rails.application.config.bodymedia[:redirect_uri] = case Rails.env 
  when 'production' then "http://YOUR PRODUCTION URL/bodymedia/callback" 
  when 'development' then "http://localhost:3000/bodymedia/callback"
  when 'test' then "http://localhost:3000/bodymedia/callback"
  else nil
end
