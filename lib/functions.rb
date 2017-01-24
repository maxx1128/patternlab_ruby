
module PL_functions

  # Data for the main navigation
  def navStructure

    direct_root = '../patternlab/lib/views/source/'
    levelOne = Dir.entries(direct_root).select { |item| item[0,1] != '.' && !item.end_with?(".md") && !item.end_with?(".json") }

    levelTwo = []
    levelThree = []
    fullNav = []

    direct_root_start = direct_root.split('/')[1]
    titleLength = 13 + direct_root_start.length

    levelOne.each_with_index do |item, index|
      
      twoPath = direct_root + item
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

    return fullNav

    # Is there a way to get the names of the last two folders and set them as the "templates" and "pages" group? This way if the name of the folders change, the logic around them all changes.
  end


  # Getting the basic pattern data files merged and returned
  # Doesn't include page-specific data
  def get_data

    pattern_data_file = File.read("../patternlab/lib/assets/data/data.json")
    pattern_data = JSON.parse(pattern_data_file)

    data_files = Dir.glob("../patternlab/lib/views/data/*.json")

    data_files.each do |data|

      data_name = data.split("/")[-1]
      data_file = File.read(data)
      data_hash = JSON.parse(data_file)

      pattern_data = pattern_data.merge(data_hash) unless data_name == "data.json"
    end

    return pattern_data
  end


  # Get data about for the templates, pages and psuedo pages
  def pages_data

    all_data_files = Dir.glob("../patternlab/lib/views/source/03-templates/**/*.json")
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