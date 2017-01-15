require 'bundler/setup'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'erb'
require 'sass'

require_relative "./functions"


get '/css/:stylesheet.css' do |stylesheet|
  scss :"scss/#{stylesheet}"
end






def navStructure

  direct_root = '../patternlab/lib/views/source/'
  levelOne = Dir.entries(direct_root).select { |item| item[0,1] != '.' }
  levelTwo = []
  levelThree = []
  fullNav = []

  direct_root_start = direct_root.split('/')[1]
  titleLength = 13 + direct_root_start.length

  levelOne.each_with_index do |item, index|
    
    twoPath = direct_root + item
    new_path2 = Dir.entries(twoPath).select { |item| item[0,1] != '.' }

    fullNav[index] = {}

    fullNav[index]['label'] = item
    fullNav[index]['path'] = twoPath.strip[titleLength..-1] + '/'
    fullNav[index]['submenu'] = []


    new_path2.each_with_index do |item2, index2|

      threePath = twoPath + '/' + item2
      new_path3 = Dir.entries(threePath).select { |item| item[0,1] != '.' }

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


# For the different templates, have templates for items with one and two parameters before the file name work as listing all files in that listing?
# Ones with three will always be showing individual ones, and will focus on that one file


get '/' do

  @title = 'Practice!'
  @nav = navStructure

  erb :index, {
    :layout => :'templates/layout'
  }
end


# For showing all patterns in a category
get '/source/:lvl1/' do

  @title = params[:lvl1].capitalize
  @nav = navStructure
  @lvl1 = params[:lvl1]

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

  file_contents = 'source/#{params[:lvl1]}/#{params[:lvl2]}/#{params[:lvl3]}'


  erb :"source/#{params[:lvl1]}/#{params[:lvl2]}/#{params[:lvl3]}", {
    :layout => :'templates/layout'
  }
end






not_found do

  @title = 'Not found!'

  erb :index, {
    :layout => :'templates/layout'
  }
end


