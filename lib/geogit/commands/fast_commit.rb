java_import org.geogit.api.ObjectId
java_import org.geogit.api.RevCommit
java_import org.geogit.api.porcelain.CommitOp
java_import org.geogit.api.porcelain.DiffOp

module GeoGit
  module Command
    class FastCommit < GenericCommand
      def initialize(geogit, repo_path, message, author_name = nil, author_email = nil)
        # transaction_id
        @geogit = geogit
        @repo_path = repo_path
        @message = message
        @author_name = author_name
        @author_email = author_email
      end
      
      def run
        geogit = @geogit || GeoGit::Instance.new(@repo_path).instance

        commit_op = geogit.command(CommitOp.java_class)
        diff_op = geogit.command(DiffOp.java_class)

        commit = commit_op.set_author(
          @author_name,
          @author_email
        ).set_message(
          @message
        ).set_allow_empty(
          true
        ).set_all(
          true
        ).call
        #.set_amend(false)
        #.set_path_filters(nil)

        parent_id = commit.parent_n(0).or(ObjectId::NULL)

        diff = diff_op.set_old_version(
          parent_id
        ).set_new_version(
          commit.id
        ).call.to_a

        changes = [].tap do |c|
          diff.each {|entry| c << "CHANGE TYPE: #{entry.change_type}"}
        end

        commit
      end
    end
  end
end

