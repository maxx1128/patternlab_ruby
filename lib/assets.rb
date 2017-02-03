require 'sinatra/base'
require 'sprockets'
require 'sass'
require 'uglifier'

class PL_assets < Sinatra::Base


#   get '/css/:stylesheet.css' do |stylesheet|
#     scss :"../assets/scss/#{stylesheet}"
#   end

  set :environment, Sprockets::Environment.new

  # append assets paths
  environment.append_path "assets/scss"
  environment.append_path "assets/js"

  # compress assets
  environment.js_compressor  = :uglify
  environment.css_compressor = :scss

  # get assets
  get "/assets/*" do
    env["PATH_INFO"].sub!("/assets", "")
    settings.environment.call(env)
  end

end