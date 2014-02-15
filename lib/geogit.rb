# -*- encoding: utf-8 -*-
$: << File.expand_path(File.dirname(__FILE__))

if defined? JRUBY_VERSION
  require 'java'
  require 'faraday'
  require 'multi_json'

  Dir[File.join(File.expand_path('..', __FILE__), '..', 'geogit-libs', '*.jar')].each {|jar| require jar}

  require 'geogit/geogit'
  require 'geogit/configuration'
  require 'geogit/commands'

  java_import java.io.ByteArrayInputStream

  else
  abort "JRuby is required for this application (http://jruby.org)"
end

module GeoGit
  extend self
  extend Configuration

  class << self
    def create_or_init_repo(repo_path)
      expanded_path = File.expand_path repo_path

      unless Dir.exist? expanded_path
        Dir.mkdir expanded_path
      end

      GeoGit::Command::Init.new(expanded_path).run
    end

    def add_and_commit(repo_path)
      geogit = geogit_from_repo(repo_path)
      repo_trees(repo_path).each do |tree|
        tree_paths = tree_paths(repo_path,tree)
        add(geogit,repo_path,tree_paths)
        commit(geogit,repo_path,tree_paths)
      end
      geogit.close
    end

    def geogit_from_repo(repo_path)
      GeoGit::Instance.new(repo_path).instance
    end

    def repo_trees(repo)
      GeoGit::Command::Tree.new(repo).run
    end
    def repo_tree_path(repo,tree)
      GeoGit::Command::Tree.new(repo, tree).run
    end
    def tree_paths(repo,tree)
      repo_tree_path(repo,tree).collect { |path| "#{tree}/#{path}" }
    end

    def add(geogit,repo_path,tree_paths)
      tree_paths.each do |tree_path|
        GeoGit::Command::FastAdd.new(geogit, repo_path, tree_path).run
      end
    end

    def commit(geogit,repo_path,tree_paths)
      tree_paths.each do |tree_path|
        GeoGit::Command::FastCommit.new(geogit, repo_path, "imported_#{tree_path}").run
      end
    end

    def import_shapefile(repo_path, shapefile)
      GeoGit::Command::ImportShapefile.new(repo_path, shapefile).run
      add_and_commit repo_path
    end

    def import_geojson(repo_path, geojson, fid_attribute = nil)
      GeoGit::Command::ImportGeoJSON.new(repo_path, geojson, fid_attribute).run
      add_and_commit repo_path
    end

    def import_github_repo(repo)
      raise RuntimeError.new 'GitHub client_id and/or client_secret not specified in configuration' unless GeoGit.github && GeoGit.github[:client_id] && GeoGit.github[:client_secret]

      client_details = "client_id=#{GeoGit.github[:client_id]}&client_secret=#{GeoGit.github[:client_secret]}"

      repos_path = GeoGit.repos_path || File.expand_path('~/data/repos')
      repo_path = File.join repos_path, repo.split('/').last

      # create repository if does not exist
      create_or_init_repo repo_path

      # start basic timer
      start = Time.now

      commits = MultiJson.load Faraday.get("https://api.github.com/repos/#{repo}/commits?#{client_details}").body

      size = commits.size

      commits.reverse.each_with_index do |commit, i|
        puts "Processing commit: #{i + 1} of #{size}"

        commit_details = MultiJson.load Faraday.get("#{commit['url']}?#{client_details}").body

        committer = commit['commit']['committer']
        commit_message = commit['commit']['message'] || "git: #{commit['sha']}"

        files_to_commit = false

        commit_details['files'].each do |file|
          if file['filename'].downcase.end_with? '.geojson'
            # faraday_middleware gem has compatibility issues with faraday >= 0.9.0
            #conn = Faraday.new("#{file['raw_url']}?#{client_details}") do |c|
            #  c.use FaradayMiddleware::FollowRedirects
            #  c.adapter :net_http
            #end
            
            raw_url = "https://raw2.github.com/#{repo}/#{file['raw_url'].split('raw/').last}"

            conn = Faraday.new("#{raw_url}?#{client_details}")

            geojson = conn.get.body

            fid_attribute = MultiJson.load(geojson)['features'].first['properties'].keys.first

            geojson_bytes = ByteArrayInputStream.new geojson.to_java_bytes

            GeoGit::Command::ImportGeoJSON.new(repo_path, geojson_bytes, fid_attribute).run
            GeoGit::Command::Add.new(repo_path).run

            files_to_commit = true
          end
        end
        
        #TODO: Deal with timestamp
        GeoGit::Command::Commit.new(repo_path, commit_message, committer['name'], committer['email']).run if files_to_commit
      end

      "Imported #{size} commits from #{repo} in #{Time.now - start} seconds"
    end

    def import_github_geojson(repo_path, url, fid_attribute = nil)
      geojson = ByteArrayInputStream.new Faraday.get(url).body.to_java_bytes
      GeoGit::Command::ImportGeoJSON.new(repo_path, geojson, fid_attribute).run
      add_and_commit repo_path
    end
  end
end

