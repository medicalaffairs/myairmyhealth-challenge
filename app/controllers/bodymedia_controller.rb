require 'oauth'

class BodymediaController < ApplicationController

  before_filter :authenticate_user!

 
  def new
  end

  def create
    access_token = session[:request_token].get_access_token

    auth_hash ={
      'provider' => 'bodymedia', 
      'uid' => "0", 
      'credentials' => {
        'token' => access_token.token,
        'auth_expiration' => access_token.params[:xoauth_token_expiration_time],
        'auth_secret' => access_token.params[:oauth_token_secret]
      }
    }

    if DeviceAuthorization.create_or_update_from_hash(auth_hash, current_user)
      redirect_to user_profile_url and return
    else
      redirect_to :failure
    end
   end

  def failure
    render :text => "Sorry, but you didn't allow access to our app!"
  end

  def consumer 
  	OAuth::Consumer.new(::Rails.application.config.bodymedia[:key],
  		::Rails.application.config.bodymedia[:shared_secret], 
  		{
  			:site=>"https://api.bodymedia.com",
  			:http_method        => :get,
        :request_token_path => "/oauth/request_token",
        :access_token_path  => "/oauth/access_token",
        :authorize_path     => "/oauth/authorize",
        :scheme => :header, 
        :oauth_version => "1.0"
      }
  		)
  end

  def authorize
  	session[:request_token] = consumer.get_request_token
    url ="https://api.bodymedia.com/oauth/authorize?oauth_callback=#{::Rails.application.config.bodymedia[:redirect_uri]}"+
	       "&api_key=#{::Rails.application.config.bodymedia[:key]}&oauth_token=#{session[:request_token].token}"
    redirect_to url 
  end

end

