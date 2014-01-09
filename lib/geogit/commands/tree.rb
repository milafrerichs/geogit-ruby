java_import org.geogit.api.plumbing.LsTreeOp

module GeoGit
  module Command
    class Tree < GenericCommand
      def initialize(repo_path, ref = nil)
        @repo_path = repo_path
        @ref = ref
      end

      def run
        geogit = GeoGit::Instance.new(@repo_path).instance

        command = geogit.command(LsTreeOp.java_class)
          .set_reference(@ref)
          .set_strategy(LsTreeOp::Strategy::CHILDREN)

        trees = command.call

        trees.map {|t| t.name}
      ensure
        geogit.close
      end
    end
  end
end

