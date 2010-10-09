$: << File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
require 'sinatra'
require 'bundler'
require 'sinatra/base'
Bundler.require(:test)


set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false



