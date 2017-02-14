require 'bundler/setup'
Bundler.setup :default
require 'sinatra'
require 'sinatra/base'
require 'sinatra/reloader' if development?
require 'erb'
require "rdiscount"
require 'json'
require 'sass'

require 'sprockets'
require 'uglifier'

require 'byebug'

require_relative "assets"
require_relative "functions"



# Universal controls stuck to the bottom right that can be expanded or collapsed?
# Control the code tabs being shown for all elements on the page?
# Could this carry over using Ruby data somehow?


class PatternLab < Sinatra::Base

  # Include the needed functions
  include PL_functions

  # Setup reloader whenever changes are saved
  configure :development do
    register Sinatra::Reloader
  end



  # Homepage
  get '/' do

    # `byebug

    @config = config_data
    @title = 'Homepage!'
    @nav = navStructure


    erb :index, {
      :layout => :'layouts/basic'
    }
  end


  # For static pages
  get '/pages/:title/' do

    @config = config_data
    @title = params[:title].gsub('-', ' ')[3..-1].capitalize
    @title_raw = params[:title]
    @nav = navStructure


    markdown :"pages/#{params[:title]}", {
      :layout => :'layouts/page',
      :layout_engine => :erb
    }
  end

  get '/pages/:parent/:title/' do

    @config = config_data
    @title = params[:title].gsub('-', ' ')[3..-1].capitalize
    @title_raw = params[:title]
    @nav = navStructure


    markdown :"pages/#{params[:parent]}/#{params[:title]}", {
      :layout => :'layouts/page',
      :layout_engine => :erb
    }
  end



  # For showing all patterns and subcategories in a category
  get '/source/:lvl1/' do

    @config = config_data
    @title = params[:lvl1].gsub('-', ' ')[3..-1].capitalize
    @title_raw = params[:lvl1]
    @nav = navStructure
    @lvl1 = params[:lvl1]


    @descr_exists = File.exist?("../#{@config["name"]}/lib/views/source/#{@lvl1}.md")

    @data = get_data(@lvl1)

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

    @config = config_data
    @title = params[:lvl2][3..-1].gsub('-', ' ').capitalize
    @title_raw = params[:lvl2]
    @nav = navStructure
    @lvl1 = params[:lvl1]
    @lvl2 = params[:lvl2]


    @descr_exists = File.exist?("../#{@config["name"]}/lib/views/source/#{@lvl1}/#{@lvl2}.md")
    
    @data = get_data(@lvl1)

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

    @config = config_data
    templates = @config["templates_page"]

    @title = params[:lvl3][3..-1].gsub('-', ' ').sub('__', ' ').capitalize
    @title_raw = params[:lvl3].gsub('-', ' ').sub('__', ' ').capitalize
    @nav = navStructure
    @lvl1 = params[:lvl1]
    @lvl2 = params[:lvl2]
    @lvl3 = params[:lvl3]


    page_data_path = "../#{@config["name"]}/lib/views/source/#{templates}/#{@lvl2}/#{@lvl3.split("__").first}.json"

    @page_data_exists = File.exist?(page_data_path)

    # If it's a page, get the needed page or psuedo page data
    if @lvl1 == 'pages' && @page_data_exists
      
      default_data = get_data('02-patterns') # Automatically get one before before this one?

      page_data_file = File.read(page_data_path)
      page_data = JSON.parse(page_data_file)

      @data = default_data.merge(page_data)

      # If this is a psuedo pattern, also merge the extra data
      if @lvl3.include? "__"

        psuedo_data_file = File.read("../#{@config["name"]}/lib/views/source/#{templates}/#{@lvl2}/#{@lvl3.sub("__", "~")}.json")
        psuedo_data = JSON.parse(psuedo_data_file)

        @data = default_data.merge(psuedo_data)

      end

      erb :"source/#{templates}/#{@lvl2}/#{@lvl3.split("__").first}", {
        :layout => :'layouts/single'
      }
    else
      @data = get_data('02-patterns') # Automatically get one before before this one?

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

