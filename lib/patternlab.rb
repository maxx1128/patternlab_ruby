require 'bundler/setup'
require 'sinatra'
require 'sinatra/base'
require 'sinatra/reloader' if development?
require 'erb'
require "rdiscount"
require 'json'
require 'sass'

require_relative "assets"
require_relative "functions"



=begin

Prepend numbers to lvl1 category folders, but remove these for all the output?

Purpose is to control the order of the folders, not let it be alphabetical

=end



=begin

For individual pattern data:

1) Look at all the levels below it (base for components) and merge all the custom pattern data for each of those
2) Then merge all the current custom pattern data over that as well

* Goes through ALL of the patterns to ensure no custom data is overlooked. Same for individual and category pages to ensure all relevant data is merged.

* Take the level
* Get all JSON files in the below file structures
* Merge each one
* Take all the JSON files from the current level
* Merge each of those
* Save the JSON merging for template and page data to the end?

* Put this into a custom function that only needs the current level as the argument? Returns the merged data. Use this function to set the @data value?

=end




class PatternLab < PL_assets

  # Include the needed functions
  include PL_functions

  # Setup reloader whenever changes are saved
  configure :development do
    register Sinatra::Reloader
  end



  # Homepage
  get '/' do

    @title = 'Practice!'
    @nav = navStructure

    erb :index, {
      :layout => :'layouts/basic'
    }
  end



  # For showing all patterns and subcategories in a category
  get '/source/:lvl1/' do

    @title = params[:lvl1].capitalize.sub('-', ' ')[3..-1]
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

  run! if __FILE__ == $0
end

