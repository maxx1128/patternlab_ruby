require 'sinatra'
require 'sinatra/reloader' if development?
require 'httparty'
require 'erb'
require 'sass'

require_relative "./functions"


get '/css/:stylesheet.css' do |stylesheet|
  scss :"scss/#{stylesheet}"
end




# Keep the API request here, put the specific selecting and filtering in the functions file?
def get_pokemon_data(poke_id)

  pokemon = HTTParty.get("http://pokeapi.co/api/v2/pokemon/#{poke_id}")
  parsed_pokemon_data = JSON.parse(pokemon.body)

  poke_name = parsed_pokemon_data["forms"][0]["name"].split.map(&:capitalize).join(' ')
  id = parsed_pokemon_data["id"]

  sprite_url_regular = parsed_pokemon_data["sprites"]["front_default"]
  sprite_url_shiny = parsed_pokemon_data["sprites"]["front_shiny"]


  types = parsed_pokemon_data["types"].map { |type_data| type_data["type"]["name"].split.map(&:capitalize).join(' ') }


  stats = parsed_pokemon_data["stats"].map { |type_data| type_data["base_stat"].to_s }
  stat_names = parsed_pokemon_data["stats"].map { |type_data| type_data["stat"]["name"].sub('-', ' ').split(/ |\_/).map(&:capitalize).join(" ") }
  full_stats = Hash[stat_names.reverse.zip stats.reverse]


  abilities = parsed_pokemon_data["abilities"];

  abilities.each_with_index do |item, i|
    name = item["ability"]["name"]
    ability_api = HTTParty.get("http://pokeapi.co/api/v2/ability/#{name}")
    parsed_ability_data = JSON.parse(ability_api.body)

    ability_descr = parsed_ability_data["effect_entries"][0]["short_effect"]

    abilities[i]["ability"]["name"] = abilities[i]["ability"]["name"].sub('-', ' ').split(/ |\_/).map(&:capitalize).join(" ")

    abilities[i]["description"] = ability_descr
    abilities[i]["id"] = item["ability"]["url"].split("/")[6].to_i
  end


  pokemon_num = parsed_pokemon_data["id"]
  prev_id = pokemon_num - 1
  next_id = pokemon_num + 1


  pokemon_species = HTTParty.get("http://pokeapi.co/api/v2/pokemon-species/#{poke_id}")
  parsed_pokemon_species_data = JSON.parse(pokemon_species.body)

  descriptions_english = []
  descriptions_full = parsed_pokemon_species_data["flavor_text_entries"]


  # Create different overall color schemes for each?
  color = parsed_pokemon_species_data["color"]["name"]


  growth_rate = parsed_pokemon_species_data["growth_rate"]["name"]

  # Evolution logic below
  evolution_api = parsed_pokemon_species_data["evolution_chain"]["url"]
  pokemon_evolution = HTTParty.get(evolution_api)
  parsed_pokemon_evolution_data = JSON.parse(pokemon_evolution.body)

  evolution_start = parsed_pokemon_evolution_data["chain"]["species"]["name"]
  evolution_start_id = parsed_pokemon_evolution_data["chain"]["species"]["url"].split("/")[6].to_i
  evolution_chain = parsed_pokemon_evolution_data["chain"]["evolves_to"]


  # This is all the data being returned in one variable
  full_pokemon_data = {
    "poke_name" => poke_name,
    "id" => id,
    "sprite_url_regular" => sprite_url_regular,
    "sprite_url_shiny" => sprite_url_shiny,
    "types" => types,
    "full_stats" => full_stats,
    "abilities" => abilities,
    "prev_id" => prev_id,
    "next_id" => next_id,
    "descriptions_full" => descriptions_full,
    "color" => color,
    "growth_rate" => growth_rate,
    "evolution_start" => evolution_start,
    "evolution_start_id" => evolution_start_id,
    "evolution_chain" => evolution_chain
  }

  return full_pokemon_data
end




total_pokemon = 721



get '/' do

  @title = 'Welcome to the Pokedex!'

  erb :index, {
    :layout => :'templates/layout',
  }
end


get '/type/:type' do
  type = params[:type]
  pokemon = HTTParty.get("http://pokeapi.co/api/v2/type/#{type}")
  parsed_type_data = JSON.parse(pokemon.body)

  @type = type

  @pokemon = parsed_type_data['pokemon']


  @title = "#{@type.capitalize} Pokemon!"

  erb :type, {
    :layout => :'templates/layout',
  }
end


get '/color/:color' do
  color = params[:color]
  pokemon = HTTParty.get("http://pokeapi.co/api/v2/pokemon-color/#{color}")
  parsed_color_data = JSON.parse(pokemon.body)

  @color = color

  @pokemon = parsed_color_data['pokemon_species']


  @title = "#{@color.capitalize} Pokemon!"

  erb :color, {
    :layout => :'templates/layout',
  }
end


get '/ability/:ability' do
  ability = params[:ability]
  pokemon = HTTParty.get("http://pokeapi.co/api/v2/ability/#{ability}")
  parsed_ability_data = JSON.parse(pokemon.body)

  @ability = parsed_ability_data['name']
  @ability_descr = parsed_ability_data['effect_entries']

  @pokemon = parsed_ability_data['pokemon']


  @title = "Ability: #{@ability.capitalize}"

  erb :ability, {
    :layout => :'templates/layout',
  }
end


get '/pokemon/:pokemon_id' do
  pokemon_id = params[:pokemon_id]

  @full_data = get_pokemon_data(pokemon_id)

  id = @full_data["id"]
  poke_name = @full_data["poke_name"]

  puts poke_name

  @title = "##{id}: #{poke_name}"

  erb :pokemon, {
    :layout => :'templates/layout',
  }
end



post '/search' do

  pokemon_id = params[:poke_search]

  @full_data = get_pokemon_data(pokemon_id)

  id = @full_data["id"]
  poke_name = @full_data["poke_name"]

  puts poke_name

  @title = "##{id}: #{poke_name}"

  erb :pokemon, {
    :layout => :'templates/layout',
  }
end


