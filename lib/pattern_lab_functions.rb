
module PatternLabFunctions

  ROOT_DIR = File.basename(Dir.getwd)

  CONFIG_ROOT = "../#{ROOT_DIR}/lib/config.json"
  SOURCE_ROOT = "../#{ROOT_DIR}/lib/views/source/"
  PAGES_ROOT = "../#{ROOT_DIR}/lib/views/pages/"
  
  CONFIG_FILE = File.read(CONFIG_ROOT)
  CONFIG_DATA = JSON.parse(CONFIG_FILE)

  

  

  def get_config_data
    config_file = File.read(CONFIG_ROOT)
    config_data = JSON.parse(config_file)

    config_data
  end




  def nav_structure
    nav = []
    create_nav(PAGES_ROOT, 'pages', nav)
    create_nav(SOURCE_ROOT, 'source', nav)

    nav = nav.uniq { |nav_item| nav_item[:label] }

    nav
  end



  def create_nav(dir, dir_root, nav_set, dir_lead = nil)

    if dir_root === "source"
      entries_files = Dir.entries(dir).reject { |str| str =~ /^\.{1,2}/ || str.end_with?('.md') || str.end_with?('.json') }
    else
      entries_files = Dir.entries(dir).reject { |str| str =~ /^\.{1,2}/ }
    end


    entries_files.each do |entry|

      entry_path = File.join(dir, entry)
      
      if File.directory?(entry_path)
        nav_set << { path: "/#{dir_root}#{dir_lead}/#{entry}/",
                     label: File.basename(entry, File.extname(entry)),
                     label_display: File.basename(entry, File.extname(entry)).gsub(/[0-9]+-/, "").gsub('-', ' ').split.map(&:capitalize).join(' '),
                     section: dir_root,
                     submenu: [] }
        create_nav(entry_path, dir_root, nav_set.last[:submenu], "#{dir_lead}/#{entry}")
      
      else
        entry = entry.gsub(".erb", "").gsub(".md", "")

        nav_set << { path: "/#{dir_root}#{dir_lead}/#{entry}/", 
                     label: entry,
                     label_display: entry.gsub(/[0-9]+-/, "").gsub('-', ' ').split.map(&:capitalize).join(' '),
                     section: dir_root, submenu: [] }
      end
      nav_set
    end
  end






  # Getting the basic pattern data files merged and returned
  # Doesn't include page-specific data
  def get_data(lvl1_label)

    pattern_data_file = File.read("../#{ROOT_DIR}/lib/assets/data/data.json")
    pattern_data = JSON.parse(pattern_data_file)

    data_files = Dir.glob("../#{ROOT_DIR}/lib/assets/data/**/**/*.json")

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

        category_data = Dir.glob("../#{ROOT_DIR}/lib/views/source/#{nav_category}/**/**/*.json")

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

    config_data = get_config_data

    all_data_files = Dir.glob("../#{ROOT_DIR}/lib/views/source/#{config_data["templates_page"]}/**/*.json")

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