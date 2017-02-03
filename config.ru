require 'bundler'
Bundler.setup :default
require 'sinatra/base'
require 'sprockets'
require 'uglifier'
require './lib/patternlab'

map '/assets' do
  environment = Sprockets::Environment.new
  environment.append_path './lib/assets/js'
  environment.append_path './lib/assets/scss'

  environment.js_compressor  = :uglify

  run environment
end

map '/' do
  run PatternLab
end
