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
require_relative "wrenchlab_functions"



# Universal controls stuck to the bottom right that can be expanded or collapsed?
# Control the code tabs being shown for all elements on the page?
# Could this carry over using Ruby data somehow?


class PatternLab < Sinatra::Base

  # Include the needed functions
  include WrenchLabFunctions

  # Setup reloader whenever changes are saved
  configure :development do
    register Sinatra::Reloader
  end

  root_dir = File.basename(Dir.getwd)



  # Homepage
  get '/' do

    # `byebug

    @config = get_config_data
    @title = "Welcome to #{@config["title"]}!"
    @nav = nav_structure




    erb :index, {
      :layout => :'layouts/basic'
    }
  end


  # For static pages
  get '/pages/:title/' do

    @config = get_config_data
    @title = params[:title].gsub(/[0-9]+-/, "").gsub('-', ' ').split.map(&:capitalize).join(' ')
    @title_raw = params[:title]
    @nav = nav_structure

    @lvl1 = params[:title]


    markdown :"pages/#{params[:title]}", {
      :layout => :'layouts/basic',
      :layout_engine => :erb
    }
  end

  get '/pages/:parent/:title/' do

    @config = get_config_data
    @title = params[:title].gsub(/[0-9]+-/, "").gsub('-', ' ').split.map(&:capitalize).join(' ')
    @title_raw = params[:title]
    @nav = nav_structure

    @lvl1 = params[:parent]
    @lvl2 = params[:title]


    markdown :"pages/#{params[:parent]}/#{params[:title]}", {
      :layout => :'layouts/basic',
      :layout_engine => :erb
    }
  end



  # For showing all patterns and subcategories in a category
  get '/source/:lvl1/' do

    @config = get_config_data
    @title = params[:lvl1].gsub(/[0-9]+-/, "").gsub('-', ' ').split.map(&:capitalize).join(' ')
    @title_raw = params[:lvl1]
    @nav = nav_structure
    @lvl1 = params[:lvl1]

    @descr_exists = File.exist?("../#{File.basename(Dir.getwd)}/lib/views/source/#{@lvl1}.md")
    @data = get_data(@lvl1)
    @pageData_files = pages_data


    # Get the nav items in this group to show as content
    nav_structure.each_with_index do |item, index|

      @category_data = item[:submenu] if item[:label] == @lvl1
    end



    erb :category, {
      :layout => :'layouts/basic'
    }
  end



  # Show showing all patterns in a subcategory
  get '/source/:lvl1/:lvl2/' do

    @config = get_config_data
    @title = params[:lvl2].gsub(/[0-9]+-/, "").gsub('-', ' ').split.map(&:capitalize).join(' ')
    @title_raw = params[:lvl2]
    @nav = nav_structure
    @lvl1 = params[:lvl1]
    @lvl2 = params[:lvl2]

    @descr_exists = File.exist?("../#{File.basename(Dir.getwd)}/lib/views/source/#{@lvl1}/#{@lvl2}.md")
    @data = get_data(@lvl1)
    @pageData_files = pages_data



    # Get the nav items in this group to show as content
    nav_structure.each do |item, index|

      if item[:label] == @lvl1

        item[:submenu].each do |item2, index2|

          @subcategory_data = item2[:submenu] if item2[:label]  == @lvl2
        end
      end
    end

    puts @subcategory_data


    erb :subcategory, {
      :layout => :'layouts/basic'
    }
  end



  # For showing individual patterns on a single page
  get '/source/:lvl1/:lvl2/:lvl3/' do

    @config = get_config_data
    templates = @config["templates_page"]

    @title = params[:lvl3].gsub(/[0-9]+-/, "").gsub('-', ' ').gsub('__', ' ').split.map(&:capitalize).join(' ')
    @title_raw = params[:lvl3].gsub('-', ' ').gsub('__', ' ').capitalize
    @nav = nav_structure
    @lvl1 = params[:lvl1]
    @lvl2 = params[:lvl2]
    @lvl3 = params[:lvl3]


    page_data_path = "../#{File.basename(Dir.getwd)}/lib/views/source/#{templates}/#{@lvl2}/#{@lvl3.split("__").first}.json"

    @page_data_exists = File.exist?(page_data_path)

    # If it's a page, get the needed page or psuedo page data
    if @lvl1 == 'pages' && @page_data_exists

      default_data = get_data('#{@config["last_component_folder"]}') # Automatically get one before before this one?

      page_data_file = File.read(page_data_path)
      page_data = JSON.parse(page_data_file)

      @data = default_data.merge(page_data)

      # If this is a psuedo pattern, also merge the extra data
      if @lvl3.include? "__"

        psuedo_data_file = File.read("../#{File.basename(Dir.getwd)}/lib/views/source/#{templates}/#{@lvl2}/#{@lvl3.sub("__", "~")}.json")
        psuedo_data = JSON.parse(psuedo_data_file)

        @data = default_data.merge(psuedo_data)

      end

      erb :"source/#{templates}/#{@lvl2}/#{@lvl3.split("__").first}", {
        :layout => :'layouts/basic'
      }
    else

      @data = get_data("#{@config["last_component_folder"]}") # Automatically get one before before this one?

      erb :"source/#{@lvl1}/#{@lvl2}/#{@lvl3}", {
        :layout => :'layouts/basic'
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

