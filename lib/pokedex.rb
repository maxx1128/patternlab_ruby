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


get '/type/:type' do
  type = params[:type]
  pokemon = HTTParty.get("http://pokeapi.co/api/v2/type/#{type}")
  parsed_pokemon_data = JSON.parse(pokemon.body)

  @type = type

  erb :type
end


get '/pokemon/:pokemon_id' do
  pokemon_id = params[:pokemon_id]
  # Why doesn't the get_data function work here instead?
  pokemon = HTTParty.get("http://pokeapi.co/api/v2/pokemon/#{pokemon_id}")
  parsed_pokemon_data = JSON.parse(pokemon.body)

  # parsed_pokemon_data = get_data("http://pokeapi.co/api/v2/pokemon/#{pokemon_id}")

  @name = parsed_pokemon_data["name"].split.map(&:capitalize).join(' ')
  @id = parsed_pokemon_data["id"]


  @sprite_url_regular = parsed_pokemon_data["sprites"]["front_default"]
  @sprite_url_shiny = parsed_pokemon_data["sprites"]["front_shiny"]


  @types = parsed_pokemon_data["types"].map { |type_data| type_data["type"]["name"].split.map(&:capitalize).join(' ') }


  stats = parsed_pokemon_data["stats"].map { |type_data| type_data["base_stat"].to_s }
  stat_names = parsed_pokemon_data["stats"].map { |type_data| type_data["stat"]["name"].sub('-', ' ').split(/ |\_/).map(&:capitalize).join(" ") }
  @full_stats = Hash[stat_names.reverse.zip stats.reverse]


  @abilities = parsed_pokemon_data["abilities"];

  @abilities.each_with_index do |item, i|
    name = item["ability"]["name"]
    ability_api = HTTParty.get("http://pokeapi.co/api/v2/ability/#{name}")
    parsed_ability_data = JSON.parse(ability_api.body)

    ability_descr = parsed_ability_data["effect_entries"][0]["short_effect"]

    @abilities[i]["ability"]["name"] = @abilities[i]["ability"]["name"].sub('-', ' ').split(/ |\_/).map(&:capitalize).join(" ")

    @abilities[i]["description"] = ability_descr
  end


  pokemon_num = parsed_pokemon_data["id"]
  @prev_id = pokemon_num - 1
  @next_id = pokemon_num + 1


  @games = parsed_pokemon_data["game_indices"].map { |type_data| type_data["version"]["name"].sub('-', ' ').split(/ |\_/).map(&:capitalize).join(" ") }


  pokemon_species = HTTParty.get("http://pokeapi.co/api/v2/pokemon-species/#{pokemon_id}")
  parsed_pokemon_species_data = JSON.parse(pokemon_species.body)

  @descriptions_english = []
  descriptions_full = parsed_pokemon_species_data["flavor_text_entries"]
  descriptions_number = 0;

  descriptions_full.each_with_index do |item|

    if item["language"]["name"] == "en"

      @descriptions_english[descriptions_number] = { "game" => item["version"]["name"], "flavor_text" => item["flavor_text"].sub('\n', ' ') }
      descriptions_number += 1
    end
  end


  erb :pokemon
end


