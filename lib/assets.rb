require 'sinatra/base'
require 'sprockets'
require 'sass'

class PL_assets < Sinatra::Base


  get '/css/:stylesheet.css' do |stylesheet|
    scss :"../assets/scss/#{stylesheet}"
  end

end