# -*- encoding: utf-8 -*-
$: << File.expand_path(File.dirname(__FILE__))

if defined? JRUBY_VERSION
  require 'java'
  require 'faraday'
  require 'multi_json'

  Dir[File.join(File.expand_path('..', __FILE__), '..', 'geogit-libs', '*.jar')].each {|jar| require jar}

  require 'geogit/geogit'
  require 'geogit/repository'
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

      repo = GeoGit::Repository.new expanded_path
      repo.create_or_init
      repo
    end

    def add_and_commit(repo_path)
      repo = GeoGit::Repository.new(repo_path)
      repo.add_and_commit
    end

    def import_shapefile(repo_path, shapefile)
      GeoGit::Command::ImportShapefile.new(repo_path, shapefile).run
      add_and_commit repo_path
    end

    def import_geojson(repo_path, geojson, fid_attribute = nil)
      GeoGit::Command::ImportGeoJSON.new(repo_path, geojson, fid_attribute).run
      add_and_commit repo_path
    end

    def import_commit(url, repo_path, commit)
      conn = Faraday.new url

      geojson = conn.get.body

      fid_attribute = MultiJson.load(geojson)['features'].first['properties'].keys.first
      geojson_bytes = ByteArrayInputStream.new geojson.to_java_bytes

      GeoGit::Command::ImportGeoJSON.new(repo_path, geojson_bytes, fid_attribute).run
      GeoGit::Command::Add.new(repo_path).run
      #TODO: Deal with commit timestamp(s)
      GeoGit::Command::Commit.new(repo_path, commit[:message], commit[:committer]['name'], commit[:committer]['email']).run
    end

    def batch_commits(commits)
      client_details = "client_id=#{GeoGit.github[:client_id]}&client_secret=#{GeoGit.github[:client_secret]}"

      [].tap do |batch|
        MultiJson.load(commits).reverse.each_with_index do |commit, i|
          committer = commit['commit']['committer']
          commit_message = commit['commit']['message'] || "git: #{commit['sha']}"

          details = MultiJson.load Faraday.get("#{commit['url']}?#{client_details}").body
        
          details['files'].each do |file|
            if file['filename'].downcase.end_with? '.geojson'
              batch << {
                committer: commit['commit']['committer'],
                message: commit['commit']['message'] || "git: #{commit['sha']}",
                raw_file: "#{file['raw_url'].split('raw/').last}"
              }
            end
          end
        end
      end
    end

    def get_commits(url)
      response = Faraday.get url

      if response.headers.include? 'link'
        follow_link response.headers['link'], batch_commits(response.body)
      else
        batch_commits response.body
      end
    end

    def follow_link(link, batch = nil)
      if link =~ /rel="next"/
        next_link = link.scan(/<(.*?)>/).first.first

        response = Faraday.get next_link

        if response.headers.include? 'link'
          follow_link response.headers['link'], batch + batch_commits(response.body)
        end  
      else
        batch
      end
    end

    def import_github_repo(repo)
      raise RuntimeError.new 'GitHub client_id and/or client_secret not specified in configuration' unless GeoGit.github && GeoGit.github[:client_id] && GeoGit.github[:client_secret]

      client_details = "client_id=#{GeoGit.github[:client_id]}&client_secret=#{GeoGit.github[:client_secret]}"

      repos_path = GeoGit.repos_path || File.expand_path('~/data/repos')
      repo_path = File.join repos_path, repo.split('/').last

      # create repository if does not exist
      geogit_repo = create_or_init_repo repo_path

      # start basic timer
      start = Time.now

      puts "Getting information about commits ..."

      url = "https://api.github.com/repos/#{repo}/commits?#{client_details}"

      batch_commits = get_commits(url)
      size = batch_commits.size

      puts "Processing commits ..."

      batch_commits.each_with_index do |commit, i|
        puts "Processing commit: #{i + 1} of #{size}"
        import_commit "https://raw2.github.com/#{repo}/#{commit[:raw_file]}?#{client_details}", repo_path, commit
      end

      puts "Imported #{size} commits from #{repo} in #{Time.now - start} seconds"
    end

    def import_github_geojson(repo_path, url, fid_attribute = nil)
      geojson = ByteArrayInputStream.new Faraday.get(url).body.to_java_bytes
      GeoGit::Command::ImportGeoJSON.new(repo_path, geojson, fid_attribute).run
      add_and_commit repo_path
    end
  end
end

