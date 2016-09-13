#!/usr/bin/ruby
require_relative 'regex_helpers'
require_relative 'get_map_from_dir'

current_path = File.expand_path(__FILE__)
maps_path = "#{File.dirname(File.dirname(current_path))}/custom/replace_maps"
map_file = "#{maps_path}/#{ARGV[0]}"
map = get_map_form_file(map_file)
replace_mapped_pathes(map, ARGV[1], ARGV[2], ARGV[3], ARGV[4], ARGV[5], ARGV[6])
