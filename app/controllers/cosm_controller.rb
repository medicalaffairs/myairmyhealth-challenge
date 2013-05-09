require 'oauth2'

class CosmController < ApplicationController

  before_filter :authenticate_user!

  def new
  end

  def create
    token_request = client.auth_code.get_token(params['code'], 
      	:redirect_uri => ::Rails.application.config.cosm[:redirect_uri])
    token_request.options[:header_format] = "OAuth %s"
    token_string = token_request.token

    auth_hash ={
      'provider' => 'cosm', 
      'uid' => session[:feed_id], 
      'credentials' => {
        'token' => token_string
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
 
  def client
    OAuth2::Client.new(::Rails.application.config.cosm[:client_id], 
      ::Rails.application.config.cosm[:client_secret], 
      :site => 'https://cosm.com/',
      :token_url  => "/oauth/token",
      :authorize_url     => "/oauth/authenticate",
      :parse_json => true
    )
  end

  def get_feed_id
    
  end

  def authorize
    session[:feed_id] = params[:feed_id]
    redirect_to client.auth_code.authorize_url
  end

end
