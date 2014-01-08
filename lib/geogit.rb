$: << File.expand_path(File.dirname(__FILE__))

if defined? JRUBY_VERSION
  require 'java'

  Dir[File.join(File.expand_path('..', __FILE__), '..', 'geogit-libs', '*.jar')].each {|jar| require jar}

  require 'geogit/geogit'
  require 'geogit/commands/generic_command'
  require 'geogit/commands/init'
  require 'geogit/commands/log'
  require 'geogit/commands/add'
  require 'geogit/commands/commit'
else
  abort "JRuby is required for this application (http://jruby.org)"
end

module GeoGit
  class << self
    def create_or_init_repo(repo_path)
      expanded_path = File.expand_path repo_path

      unless Dir.exist? expanded_path
        Dir.mkdir expanded_path
      end

      GeoGit::Command::Init.new(expanded_path).run
    end
  end
end

