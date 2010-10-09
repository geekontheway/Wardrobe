require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'wardrobe'
require 'wardrobe_helpers'

describe 'Wardrobe' do
  include Rack::Test::Methods

  def app
     @app ||= Sinatra::Application
  end

  it "says hello" do
    get '/'
     puts last_response.inspect
  end
end