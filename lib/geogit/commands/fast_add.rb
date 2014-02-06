java_import org.geogit.api.porcelain.AddOp
java_import org.geogit.api.plumbing.merge.Conflict
java_import org.geogit.api.plumbing.merge.ConflictsReadOp

module GeoGit
  module Command
    class FastAdd < GenericCommand
      def initialize(geogit, repo_path, path_filter = nil)
        @geogit = geogit
        @repo_path = repo_path
        @path_filter = path_filter
      end

      def run
        geogit = @geogit || GeoGit::Instance.new(@repo_path).instance

        conflicts = geogit.command(ConflictsReadOp.java_class).call
        pre_unstaged = geogit.get_repository.get_working_tree.count_unstaged(@path_filter)

        return nil if pre_unstaged.get_count == 0 && conflicts.is_empty

        command = geogit.command(AddOp.java_class)

        command.add_pattern @path_filter unless @path_filter.nil?
        work_tree = command.set_update_only(false).call

        staged = geogit.get_repository.get_index.count_staged(nil)
        unstaged = work_tree.count_unstaged(nil)

        [
          "#{staged.get_features_count} features and #{staged.get_trees_count} trees staged for commit",
          "#{unstaged.get_features_count} features and #{unstaged.get_trees_count} trees not staged for commit"
        ]
      end
    end
  end
end

