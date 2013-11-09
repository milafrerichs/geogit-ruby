$: << File.expand_path(File.dirname(__FILE__))

if defined? JRUBY_VERSION
  require 'java'

  Dir[File.join(File.expand_path('..', __FILE__), '..', 'geogit-libs', '*.jar')].each {|jar| require jar}

  require 'geogit/geogit'
  require 'geogit/commands/generic_command'
  require 'geogit/commands/log'
else
  abort "JRuby is required for this application (http://jruby.org)"
end

