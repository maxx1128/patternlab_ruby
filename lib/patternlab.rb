require 'bundler/setup'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'erb'
require "rdiscount"
require 'sass'
require 'json'

require_relative "./functions"


get '/css/:stylesheet.css' do |stylesheet|
  scss :"scss/#{stylesheet}"
end






def navStructure

  direct_root = '../patternlab/lib/views/source/'
  levelOne = Dir.entries(direct_root).select { |item| item[0,1] != '.' && !item.end_with?(".md") }
  levelTwo = []
  levelThree = []
  fullNav = []

  direct_root_start = direct_root.split('/')[1]
  titleLength = 13 + direct_root_start.length

  levelOne.each_with_index do |item, index|
    
    twoPath = direct_root + item
    new_path2 = Dir.entries(twoPath).select { |item| item[0,1] != '.' && !item.end_with?(".md") }

    fullNav[index] = {}

    fullNav[index]['label'] = item
    fullNav[index]['path'] = twoPath.strip[titleLength..-1] + '/'
    fullNav[index]['submenu'] = []


    new_path2.each_with_index do |item2, index2|

      threePath = twoPath + '/' + item2
      new_path3 = Dir.entries(threePath).select { |item| item[0,1] != '.' && !item.end_with?(".md") }

      fullNav[index]['submenu'][index2] = {}
      fullNav[index]['submenu'][index2]['label'] = item2.chomp('.erb')
      fullNav[index]['submenu'][index2]['path'] = threePath.strip[titleLength..-1].chomp('.erb') + '/'
      fullNav[index]['submenu'][index2]['submenu'] = new_path3

      new_path3.each_with_index do |item3, index3|

        fourPath = threePath + '/' + item3

        fullNav[index]['submenu'][index2]['submenu'][index3] = {}
        fullNav[index]['submenu'][index2]['submenu'][index3]['label'] = item3.chomp('.erb')
        fullNav[index]['submenu'][index2]['submenu'][index3]['path'] = fourPath.strip[titleLength..-1].chomp('.erb') + '/'
      end
    end
  end

  return fullNav
end

pattern_data_file = File.read("../patternlab/lib/views/data/data.json")
pattern_data = JSON.parse(pattern_data_file)


# For the different templates, have templates for items with one and two parameters before the file name work as listing all files in that listing?
# Ones with three will always be showing individual ones, and will focus on that one file


get '/' do

  @title = 'Practice!'
  @nav = navStructure

  erb :index, {
    :layout => :'templates/layout'
  }
end



# For the routes going to all components, link to the general JSON data.
# Checks for local data to use next to that file? If not there, it uses the default data. Does this in the include file?

# For the routes in templates, link to specific JSON data that's adjacent to the file with the same title but a JSON extension



# For showing all patterns in a category
get '/source/:lvl1/' do

  @title = params[:lvl1].capitalize
  @nav = navStructure
  @lvl1 = params[:lvl1]

  puts @nav

  @descr_exists = File.exist?("../patternlab/lib/views/source/#{@lvl1}.md")
  @data_exists = File.exist?("../patternlab/lib/views/source/#{@lvl1}.md")

  @data = pattern_data

  navStructure.each_with_index do |item, index|

    @category_data = item['submenu'] if item['label'] == @lvl1
  end

  erb :category, {
    :layout => :'templates/layout'
  }
end


# Show showing all patterns in a subcategory
get '/source/:lvl1/:lvl2/' do

  @title = params[:lvl2].capitalize
  @nav = navStructure
  @lvl1 = params[:lvl1]
  @lvl2 = params[:lvl2]

  @descr_exists = File.exist?("../patternlab/lib/views/source/#{@lvl1}/#{@lvl2}.md")
  @data = pattern_data

  @subcategory_data

  navStructure.each_with_index do |item, index|

    if item['label'] == @lvl1

      item['submenu'].each_with_index do |item2, index2|

        if item2['label']  == @lvl2

          @subcategory_data = item2['submenu']
        end
      end
    end
  end


  erb :subcategory, {
    :layout => :'templates/layout'
  }
end


# For showing individual patterns on a single page
get '/source/:lvl1/:lvl2/:lvl3/' do

  @title = params[:lvl3].capitalize
  @nav = navStructure

  @data = pattern_data

  file_contents = 'source/#{params[:lvl1]}/#{params[:lvl2]}/#{params[:lvl3]}'


  erb :"source/#{params[:lvl1]}/#{params[:lvl2]}/#{params[:lvl3]}", {
    :layout => :'templates/layout'
  }
end


# For templates of different pages
get '/source/templates/:category/:name' do

  @category = params[:category]
  @name = params[:name]


  erb :"source/#{@category}/#{@name}", {
    :layout => :'templates/layout' # replace this with a different, simpler one later
  }
end






not_found do

  @title = 'Not found!'

  erb :index, {
    :layout => :'templates/layout'
  }
end


