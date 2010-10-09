require 'sinatra/base'
require 'openid/store/filesystem'

module Sinatra
  module WardrobeHelpers

    def current_hour()
      Time.now - ((Time.now.min * 60) + (Time.now.sec))
    end

     def parse_tags(s)
      s.downcase.split(",").each do |word|
         word.strip! || word
      end
     end

     def root_url
       request.url.match(/(^.*\/{2}[^\/]*)/)[1]
     end

    def openid_consumer
      @openid_consumer ||= OpenID::Consumer.new(session,
        OpenID::Store::Filesystem.new("#{File.dirname(__FILE__)}/tmp/openid"))
    end

    def current_user
      unless session[:user].nil?
        session[:user]
      end
    end
   end
  helpers WardrobeHelpers
end
