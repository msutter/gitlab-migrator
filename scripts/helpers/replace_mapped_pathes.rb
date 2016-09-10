#!/usr/bin/ruby
require 'fastlane'
require 'rbconfig'
require 'pry'

def replace_mapped_pathes(gitlab_src, gitlab_dst, path_map)
  replace_regexps = get_mapped_regex(gitlab_src, gitlab_dst, path_map)
  replace_regexps.each do |orig_text,regex|
    command = sed_command(orig_text, regex)
    puts command
    result = %x(#{command})
    puts result
  end
end

def get_mapped_regex(gitlab_src, gitlab_dst, path_map)
  replace_regexps = {}
  path_map.each do |k,v|
    group_path_src = "#{gitlab_src}/#{k}"
    group_path_dst = "#{gitlab_dst}/#{v}"
    gitlab_src_reg = Regexp.quote(group_path_src)
    gitlab_src_reg.sub! '/', '\\/'
    group_path_dst.sub! '/', '\\/'
    replace_regexps[group_path_src] = "s/#{gitlab_src_reg}/#{group_path_dst}/g"
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
replace_mapped_pathes(ARGV[0], ARGV[1], path_map)
