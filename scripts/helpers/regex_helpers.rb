#!/usr/bin/ruby
require 'rbconfig'

def replace_mapped_pathes(
  path_map,
  search_prefix  = nil,
  replace_prefix = nil,
  search_suffix  = nil,
  replace_suffix = nil,
  start_line = false,
  end_line = false
  )

  replace_regexps = get_replace_mapped_regexs(path_map, search_prefix, replace_prefix, search_suffix, replace_suffix, start_line, end_line)
  replace_regexps.each do |orig_text,regex|
    command = sed_command(orig_text, regex)
    puts command
    result = %x(#{command})
    puts result
  end
end

def get_replace_mapped_regexs(
  path_map,
  search_prefix  = nil,
  replace_prefix = nil,
  search_suffix  = nil,
  replace_suffix = nil,
  start_line = false,
  end_line = false
  )

  regexs = {}

  path_map.each do |k,v|
    search_string = search_prefix || search_suffix ? "#{search_prefix}#{k}#{search_suffix}" : k
    replace_string = replace_prefix || replace_suffix ? "#{replace_prefix}#{v}#{replace_suffix}" : v
    regexs[search_string] = get_replace_regexp(search_string, replace_string, start_line, end_line)
  end
  regexs
end

def get_replace_regexp(find_text, replace_text, start_line=false, end_line=false)
    find_text_reg = Regexp.quote(find_text)
    find_text_reg.sub! '/', '\\/'
    replace_text.sub! '/', '\\/'
    "s/#{'^' if start_line}#{find_text_reg}#{'$' if end_line}/#{replace_text}/g"
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
