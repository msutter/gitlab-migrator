#!/usr/bin/ruby
require 'json'

def get_path_from_mapping(orig_path)
  raise "nedds a path as parameter" unless ARGV[0]
  path_map = JSON.load ENV["GITLAB_PATH_MAP"] || {}
  result = orig_path
  if path_map && path_map[orig_path]
    result = path_map[orig_path]
  end
  result
end
