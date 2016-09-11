#!/usr/bin/ruby
require 'rbconfig'

def replace_mapped_pathes(path_map, search_prefix=nil, replace_prefix=nil)
  replace_regexps = get_replace_regexs(path_map, search_prefix, replace_prefix)
  replace_regexps.each do |orig_text,regex|
    command = sed_command(orig_text, regex)
    puts command
    result = %x(#{command})
    puts result
  end
end

def get_replace_regexs(path_map, search_prefix=nil, replace_prefix=nil)
  regexs = {}
  path_map.each do |k,v|
    search_string = search_prefix ? "#{search_prefix}/#{k}" : k
    replace_string = replace_prefix ? "#{replace_prefix}/#{v}" : v
    regexs[search_string] = get_replace_regexp(search_string, replace_string)
  end
  regexs
end

def get_replace_regexp(find_text, replace_text)
    find_text_reg = Regexp.quote(find_text)
    find_text_reg.sub! '/', '\\/'
    replace_text.sub! '/', '\\/'
    "s/#{find_text_reg}/#{replace_text}/g"
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
