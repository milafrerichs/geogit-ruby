module GeoGit
  module Configuration
    attr_accessor :repos_path, :github

    def configure
      yield self
    end
  end
end

