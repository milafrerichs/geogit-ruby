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
  require 'geogit/commands/import_command.rb'
  require 'geogit/commands/import_shapefile'
  require 'geogit/commands/import_geojson'
  require 'geogit/commands/tree'
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

    def add_and_commit(repo_path)
      trees = GeoGit::Command::Tree.new(repo_path).run

      trees.each do |tree|
        paths = GeoGit::Command::Tree.new(repo_path, tree).run

        paths.each do |path|
          GeoGit::Command::Add.new(repo_path, "#{tree}/#{path}", tree).run
          GeoGit::Command::Commit.new(repo_path, "imported_#{tree}/#{path}").run
        end
      end
    end

    def import_shapefile(repo_path, shapefile)
      GeoGit::Command::ImportShapefile.new(repo_path, shapefile).run
      add_and_commit repo_path
    end

    def import_geojson(repo_path, geojson)
      GeoGit::Command::ImportGeoJSON.new(repo_path, geojson).run
      add_and_commit repo_path
    end
  end
end

