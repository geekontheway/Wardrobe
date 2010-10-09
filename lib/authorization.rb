require 'sinatra/base'

module Sinatra
  module Authorization

    def authenticated?
     !!session[:openid] && !!session[:user]
    end

    def protected!
        unless authenticated?
          redirect '/login'
        end       
    end

    def logout!
        session[:openid] = nil
        session[:user] = nil
      end
  end

  register Authorization 
end
