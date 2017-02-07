require 'bundler'
Bundler.setup :default
require 'sinatra/base'
require 'sprockets'
require 'uglifier'
require 'autoprefixer-rails'
require './lib/patternlab'

map '/assets' do
  environment = Sprockets::Environment.new
  AutoprefixerRails.install(environment)

  environment.append_path './lib/assets/js'
  environment.append_path './lib/assets/scss'
  environment.append_path './lib/assets/img'

  environment.js_compressor  = :uglify

  run environment
end

map '/' do
  run PatternLab
end
