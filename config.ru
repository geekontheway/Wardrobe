$LOAD_PATH << './lib' 
require 'bundler'
require 'date'
require 'rubygems'
Bundler.setup
require './lib/wardrobe'
set :run, false
set :environment, :production
run Sinatra::Application