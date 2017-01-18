require 'bundler/setup'
require 'sinatra'
require 'sinatra/base'
require 'sinatra/reloader' if development?
require 'erb'
require "rdiscount"
require 'json'

require 'sass'
require 'uglifier'

require_relative "./functions"










get '/css/:stylesheet.css' do |stylesheet|
  scss :"../assets/scss/#{stylesheet}"
end


# Two main tasks left
# 1) Show the HTML for each pattern and template
# 2) Create psuedo-pattern data for templates which merges additional data into the page JSON



get '/' do

  @title = 'Practice!'
  @nav = navStructure

  erb :index, {
    :layout => :'layouts/basic'
  }
end



# For the routes going to all components, link to the general JSON data.
# Checks for local data to use next to that file? If not there, it uses the default data. Does this in the include file?

# For the routes in templates, link to specific JSON data that's adjacent to the file with the same title but a JSON extension




# For showing all patterns in a category
get '/source/:lvl1/' do

  @title = params[:lvl1].capitalize.sub('-', ' ')
  @nav = navStructure
  @lvl1 = params[:lvl1]

  @descr_exists = File.exist?("../patternlab/lib/views/source/#{@lvl1}.md")

  @data = get_data

  @pageData_files = pages_data


  # Get the nav items in this group to show as content
  navStructure.each_with_index do |item, index|

    @category_data = item['submenu'] if item['label'] == @lvl1
  end



  erb :category, {
    :layout => :'layouts/basic'
  }
end


# Show showing all patterns in a subcategory
get '/source/:lvl1/:lvl2/' do

  require_relative "./functions"

  @title = params[:lvl2].capitalize.sub('-', ' ')
  @nav = navStructure
  @lvl1 = params[:lvl1]
  @lvl2 = params[:lvl2]

  @descr_exists = File.exist?("../patternlab/lib/views/source/#{@lvl1}/#{@lvl2}.md")
  
  @data = get_data

  @pageData_files = pages_data

  puts @pageData_files



  # Get the nav items in this group to show as content
  navStructure.each_with_index do |item, index|

    if item['label'] == @lvl1

      item['submenu'].each_with_index do |item2, index2|

        @subcategory_data = item2['submenu'] if item2['label']  == @lvl2
      end
    end
  end


  erb :subcategory, {
    :layout => :'layouts/basic'
  }
end



# For showing individual patterns on a single page
get '/source/:lvl1/:lvl2/:lvl3/' do

  @title = params[:lvl3].capitalize.sub('-', ' ').sub('__', ' ')
  @nav = navStructure
  @lvl1 = params[:lvl1]
  @lvl2 = params[:lvl2]
  @lvl3 = params[:lvl3]

  page_data_path = "../patternlab/lib/views/source/templates/#{@lvl2}/#{@lvl3.split("__").first}.json"
  @page_data_exists = File.exist?(page_data_path)

  # If it's a page, get the needed page or psuedo page data
  if @lvl1 == 'pages' && @page_data_exists
    
    default_data = get_data

    page_data_file = File.read(page_data_path)
    page_data = JSON.parse(page_data_file)

    @data = default_data.merge(page_data)

    # If this is a psuedo pattern, also merge the extra data
    if @lvl3.include? "__"

      psuedo_data_file = File.read("../patternlab/lib/views/source/templates/#{@lvl2}/#{@lvl3.sub("__", "~")}.json")
      psuedo_data = JSON.parse(psuedo_data_file)

      @data = default_data.merge(psuedo_data)

    end

    erb :"source/templates/#{@lvl2}/#{@lvl3.split("__").first}", {
      :layout => :'layouts/single'
    }
  else
    @data = get_data

    erb :"source/#{@lvl1}/#{@lvl2}/#{@lvl3}", {
      :layout => :'layouts/single'
    }
  end 
end





not_found do

  @title = 'Not found!'

  erb :index, {
    :layout => :'layouts/basic'
  }
end


