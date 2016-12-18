require "sinatra"
require 'sinatra/reloader' if development?
require 'httparty'
require "erb"
require 'sass'

require_relative "./functions"


get '/css/:stylesheet.css' do |stylesheet|
  scss :"scss/#{stylesheet}"
end




total_pokemon = 721

random_poke = {}
random_poke_num = math 2,3
i = 0

while i < random_poke_num
  pokemon = Random.rand(total_pokemon)
  pokemon_json = get_data("http://pokeapi.co/api/v2/pokemon/#{pokemon}")
  pokemon_name = pokemon_json["name"]

  random_poke[pokemon] = pokemon_name
  i += 1
end




get '/' do
  @total = random_poke
  erb :index
end

get '/:pokemon_id' do
  pokemon_id = params[:pokemon_id].to_i
  prev_id = pokemon_id - 1
  next_id = pokemon_id + 1
  # Why doesn't the get_data function work here instead?
  pokemon = HTTParty.get("http://pokeapi.co/api/v2/pokemon/#{pokemon_id}")
  parsed_pokemon_data = JSON.parse(pokemon.body)

  # parsed_pokemon_data = get_data("http://pokeapi.co/api/v2/pokemon/#{pokemon_id}")

  @name = parsed_pokemon_data["name"].split.map(&:capitalize).join(' ')
  @id = pokemon_id

  @sprite_url_regular = parsed_pokemon_data["sprites"]["front_default"]
  @sprite_url_shiny = parsed_pokemon_data["sprites"]["front_shiny"]

  @types = parsed_pokemon_data["types"].map { |type_data| type_data["type"]["name"].split.map(&:capitalize).join(' ') }

  @prev_id = prev_id
  @next_id = next_id

  erb :pokemon
end
