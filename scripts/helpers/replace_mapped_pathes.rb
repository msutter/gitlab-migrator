#!/usr/bin/ruby
require 'json'
require 'fastlane'
require 'rbconfig'

def replace_mapped_pathes(gitlab_src, gitlab_dst, path_map)
  replace_regexps = get_mapped_regex(gitlab_src, gitlab_dst, path_map)
  replace_regexps.each do |orig_text,regex|
    puts orig_text
    puts regex
    command = sed_command(orig_text, regex)
    puts command
  end
end

def get_mapped_regex(gitlab_src, gitlab_dst, path_map)
  replace_regexps = {}
  path_map.each do |k,v|
    group_path_src = "#{gitlab_src}/#{k}"
    group_path_dst = "#{gitlab_dst}/#{v}"
    regex_src = Regexp.quote(group_path_src)
    replace_regexps[group_path_src] = "s/#{regex_src}/#{group_path_dst}/g"
  end
  replace_regexps
end

def os
  @os ||= (
    host_os = RbConfig::CONFIG['host_os']
    case host_os
    when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
      :windows
    when /darwin|mac os/
      :macosx
    when /linux/
      :linux
    when /solaris|bsd/
      :unix
    else
      raise Error::WebDriverError, "unknown os: #{host_os.inspect}"
    end
  )
end

def sed_command(orig_text, regex)
  command = ""
  case os
  when :macosx
    command = "git grep -l '#{orig_text}' | xargs sed -i '' -e '#{regex}'"
  else
    command = "git grep -l '#{orig_text}' | xargs sed -i '#{regex}'"
  end
  command
end

path_map = JSON.load ENV["GITLAB_PATH_MAP"]
replace_mapped_pathes(Arg[0], Arg[1], path_map)
