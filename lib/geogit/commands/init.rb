module GeoGit
  module Command
    class Init < GenericCommand
      def initialize(geogit, repo_path)
        @geogit = geogit
        @repo_path = repo_path
      end

      def run
        repository = @geogit.get_or_create_repository
        repository
      end
    end
  end
end

