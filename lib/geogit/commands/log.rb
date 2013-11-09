java_import org.geogit.api.porcelain.LogOp

module GeoGit
  module Command
    class Log < GenericCommand
      def initialize(repo_path, path = '', offset = 0, limit = 0)
        @repo_path = repo_path
        @path = path
        @offset = offset
        @limit = limit
      end

      def run
        geogit = GeoGit::Instance.new @repo_path
        command_locator = geogit.get_command_locator
        command = command_locator.command LogOp.java_class

        command.add_path @path unless @path.empty?

        rev_commits = command.call
        count = rev_commits.count

        commits = command.call
        
        if @offset >= 0 && @limit > 0
          unless @offset * @limit >= count
            commits = commits.drop(@offset * @limit).take(@limit)
          end
        end

        {count: count, commits: prepare_output(commits.to_a)}
      end

      private
      def prepare_output(commits)
        commits.to_a.map { |c|
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

