java_import org.geogit.api.porcelain.LogOp

module GeoGit
  module Command
    class Log < GenericCommand
      def initialize(geogit, repo_path, path = '', offset = 0, limit = 0)
        @geogit = geogit
        @repo_path = repo_path
        @path = path
        @offset = offset
        @limit = limit
      end

      def run
        command = @geogit.command(LogOp.java_class)

        command.add_path @path unless @path.empty?

        rev_commits = command.call
        count = rev_commits.count

        commits = command.call
        
        if @limit > 0
          unless @offset >= count
            commits = commits.drop(@offset).take(@limit)
          else
            commits = []
          end
        end

        {count: count, commits: prepare_output(commits.to_a)}
      end

      private
      def prepare_output(commits)
        commits.map { |c|
          {
            id: c.id.to_s,
            message: c.message,
            author: {
              name: c.author.name.isPresent ? c.author.name.get : '',
              email: c.author.email.isPresent ? c.author.email.get : ''
            },
            committer: {
              name: c.committer.name.isPresent ? c.committer.name.get : '',
              email: c.committer.name.isPresent ? c.committer.email.get : ''
            }
          }
        }
      end
    end
  end
end

