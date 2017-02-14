
module PL_functions

  CONFIG_ROOT = '../patternlab/lib/config.json'
  CONFIG_FILE = File.read(CONFIG_ROOT)
  CONFIG_DATA = JSON.parse(CONFIG_FILE)

  PROJECT_NAME = CONFIG_DATA["name"]

  SOURCE_ROOT = '../patternlab/lib/views/source/'
  PAGES_ROOT = '../patternlab/lib/views/pages/'

  

  def config_data
    config_file = File.read(CONFIG_ROOT)
    config_data = JSON.parse(config_file)

    return config_data
  end

  # Data for the main navigation
  def navStructure

    fullNav = []


    # Get the nav for the Patterns and their files

    levelOne = Dir.entries(SOURCE_ROOT).select { |item| item[0,1] != '.' && !item.end_with?(".md") && !item.end_with?(".json") }

    direct_root_start = SOURCE_ROOT.split('/')[1]
    titleLength = 13 + direct_root_start.length

    levelOne.each_with_index do |item, index|

      twoPath = SOURCE_ROOT + item
      new_path2 = Dir.entries(twoPath).select { |item| item[0,1] != '.' && !item.end_with?(".md") && !item.end_with?(".json") }

      fullNav[index] = {}

      fullNav[index]['label'] = item
      fullNav[index]['path'] = twoPath.strip[titleLength..-1] + '/'
      fullNav[index]['submenu'] = []


      new_path2.each_with_index do |item2, index2|

        threePath = twoPath + '/' + item2
        new_path3 = Dir.entries(threePath).select { |item| item[0,1] != '.' && !item.end_with?(".md") && !item.end_with?(".json") }

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


    # Get any static pages and add them to the top of the nav
    pages = Dir.entries(PAGES_ROOT).select { |item| item[0,1] != '.' && item.end_with?(".md") }

    pages_root_start = PAGES_ROOT.split('/')[1]
    pagesLength = 13 + pages_root_start.length

    pages.each_with_index.reverse_each do |item, index|

      item = item.split('.').first
      pagePath = PAGES_ROOT + item
      item_submenu = []


      if File.exists? PAGES_ROOT + item + '/'

        page_submenus = Dir.entries(PAGES_ROOT + item + '/').select { |item| item[0,1] != '.' }

        page_submenus.each_with_index do |subitem, index|

          item_submenu[index] = {}
          item_submenu[index]["label"] = subitem.split('.')[0].gsub('-', ' ')
          item_submenu[index]["path"] = pagePath.strip[pagesLength..-1] + '/' + subitem.sub('.md', '/')
        end

      end




      fullNav.unshift(
        {
          "label" => item,
          "path" => pagePath.strip[pagesLength..-1] + '/',
          "submenu" => item_submenu
        }
      )
    end

    # How will page submenus be pushed here?

    return fullNav

    # Is there a way to get the names of the last two folders and set them as the "templates" and "pages" group? This way if the name of the folders change, the logic around them all changes.
  end




  # Getting the basic pattern data files merged and returned
  # Doesn't include page-specific data
  def get_data(lvl1_label="02-patterns")

    pattern_data_file = File.read("../#{PROJECT_NAME}/lib/assets/data/data.json")
    pattern_data = JSON.parse(pattern_data_file)

    data_files = Dir.glob("../#{PROJECT_NAME}/lib/views/data/*.json")

    data_files.each do |data|

      data_name = data.split("/")[-1]
      data_file = File.read(data)
      data_hash = JSON.parse(data_file)

      pattern_data = pattern_data.merge(data_hash) unless data_name == "data.json"
    end



    # For merging all data in this or previous levels
    lvl1NavData = levelOne = Dir.entries(SOURCE_ROOT).select { |item| item[0,1] != '.' && !item.end_with?(".md") && !item.end_with?(".json") }
    reached_current_lvl = false

    lvl1NavData.each do |nav_category|

      if (reached_current_lvl == false)

        category_data = Dir.glob("../#{PROJECT_NAME}/lib/views/source/#{nav_category}/**/**/*.json")

        category_data.each do |data|
          data_name = data.split("/")[-1]
          data_file = File.read(data)
          data_hash = JSON.parse(data_file)

          pattern_data = pattern_data.merge(data_hash)
        end

        reached_current_lvl = true if nav_category == lvl1_label
      end
    end

    return pattern_data
  end


  # Get data about for the templates, pages and psuedo pages
  def pages_data

    all_data_files = Dir.glob("../#{PROJECT_NAME}/lib/views/source/03-templates/**/*.json")
    pageData_files = []

    all_data_files.map { |data| 

      data_name = data.split("/")[-1]
      pageData_files.push(
        {
          "file_name": data_name,
          "link_name": data_name.sub("~", "__").chomp(".json"),
          "label": data_name.sub("~", " ").chomp(".json")
        }
      )
    }

    return pageData_files
  end

end