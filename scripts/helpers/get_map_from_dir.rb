#!/usr/bin/ruby
def get_map_form_dir(maps_dir)
  map_files = Dir["#{maps_dir}/*"]
  map = {}
  if map_files.empty?
    puts "No mapping file found in #{maps_dir}"
  else
    map_files.each do |map_file|
      file_map = get_map_form_file(map_file)
      map.merge!(file_map)
    end
  end
  map
end

def get_map_form_file(map_file)
  map = {}
  if File.exist?(map_file)
    puts "Using map file #{map_file}"
    content = ""
    # read file and exclude commants and empty lines
    File.read(map_file).each_line do |line|
      next if line.empty?
      next if line.include? "#"
      content = content + line + "\n"
    end
    map.merge!(Hash[*content.split(/[; \n]+/)])
  else
    puts "Mapping file #{map_file} not found"
  end
  map
end
