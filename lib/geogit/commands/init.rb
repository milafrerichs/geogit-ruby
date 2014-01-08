module GeoGit
  module Command
    class Init < GenericCommand
      def initialize(repo_path)
        @repo_path = repo_path
      end

      def run
        geogit = GeoGit::Instance.new(@repo_path).instance
        repository = geogit.get_or_create_repository
        repository
      ensure
        geogit.close
      end
    end
  end
end

