require "sinatra"
require 'sinatra/reloader' if development?
require 'httparty'
require "erb"

require_relative "functions"

total_pokemon = 721

random_poke = {}
random_poke_num = 5
i = 0

def math(num1, num2)
  return num1 + num2
end

while i <= random_poke_num
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
  math1 = math 3,5
  math2 = math 5,2
  math3 = math 4,8

  pokemon_id = params[:pokemon_id].to_i
  prev_id = pokemon_id - 1
  next_id = pokemon_id + 1
  # Why doesn't the get_data function work here instead?
  pokemon = HTTParty.get("http://pokeapi.co/api/v2/pokemon/#{pokemon_id}")
  parsed_pokemon_data = JSON.parse(pokemon.body)

  # parsed_pokemon_data = get_data("http://pokeapi.co/api/v2/pokemon/#{pokemon_id}")


  @name = parsed_pokemon_data["name"].split.map(&:capitalize).join(' ')
  @id = pokemon_id
  @sprite_img_url =  "http://pokeapi.co//media//sprites//pokemon//#{pokemon_id}.png"
  @types = parsed_pokemon_data["types"].map { |type_data| type_data["type"]["name"].split.map(&:capitalize).join(' ') }

  @prev_id = prev_id
  @next_id = next_id

  erb :pokemon
end

