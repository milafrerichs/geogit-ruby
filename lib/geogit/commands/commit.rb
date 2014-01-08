java_import org.geogit.api.ObjectId
java_import org.geogit.api.RevCommit
java_import org.geogit.api.porcelain.CommitOp
java_import org.geogit.api.porcelain.DiffOp

module GeoGit
  module Command
    class Commit < GenericCommand
      def initialize(repo_path, message)
        # transaction_id, author_name, author_email
        @repo_path = repo_path
        @message = message
      end
      
      def run
        geogit = GeoGit::Instance.new(@repo_path).instance
        commit_op = geogit.command(CommitOp.java_class)
        diff_op = geogit.command(DiffOp.java_class)

        commit = commit_op.set_author(
          nil,
          nil
        ).set_message(
          message
        ).set_allow_empty(
          true
        ).set_all(
          true
        ).call
        #.set_amend(false)
        #.set_path_filters(nil)

        parent_id = commit.parent_n(0).or(ObjectId.NULL)

        diff = diff_op.set_old_version(
          parent_id
        ).set_new_version(
          commit.id
        ).call.to_a

        changes = [].tap do |c|
          diff.each {|entry| c << "CHANGE TYPE: #{entry.change_type}"}
        end

        commit
      ensure
        geogit.close
      end
    end
  end
end

