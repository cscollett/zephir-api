require './zephir_api.rb'
run Sinatra::Application

require 'rubygems'
require 'bundler'
Bundler.require(:default, ENV['RACK_ENV'].to_sym)
root = ::File.dirname(__FILE__)
require ::File.join( root, 'zephir_api' )

map "/api" do
	run ZephirApi.new
end