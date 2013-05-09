require 'oauth2'

class FoursquareController < ApplicationController

  before_filter :authenticate_user!

  def new
  end

  def create
    token_request = client.auth_code.get_token(params[:code], 
      :redirect_uri => ::Rails.application.config.foursquare[:redirect_uri])
    token_request.options[:header_format] = "OAuth %s"
    token_string = token_request.token

    auth_hash ={
      'provider' => 'foursquare', 
      'uid' => "0", 
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
    OAuth2::Client.new(::Rails.application.config.foursquare[:client_id], 
      ::Rails.application.config.foursquare[:client_secret], 
      :site => 'http://foursquare.com/',
      :token_url  => "/oauth2/access_token",
      :authorize_url     => "/oauth2/authenticate?response_type=code",
      :parse_json => true
    )
  end

  def authorize
    redirect_to client.auth_code.authorize_url(:redirect_uri => ::Rails.application.config.foursquare[:redirect_uri])
  end

  def callback
    token = client.auth_code.get_token('code_value', :redirect_uri => ::Rails.application.config.foursquare[:redirect_uri])
  end

end
