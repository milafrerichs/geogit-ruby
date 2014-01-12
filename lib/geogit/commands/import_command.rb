java_import org.geogit.geotools.plumbing.ImportOp
java_import org.geogit.geotools.plumbing.GeoToolsOpException
java_import org.geotools.data.DataStore

module GeoGit
  module Command
    class ImportCommand < GenericCommand
      def initialize(repo_path)
        @repo_path = repo_path
      end

      def get_geogit_instance
        GeoGit::Instance.new(@repo_path).instance
      end

      def get_data_store(path)
        nil
      end

      def do_import(geogit, data)
        data_store = get_data_store data

        begin
          command = geogit.command(ImportOp.java_class)
            .set_all(true)
            .set_table(nil)
            .set_alter(false)
            .set_overwrite(true)
            .set_destination_path(nil)
            .set_data_store(data_store)
            .set_fid_attribute(nil)
            .set_progress_listener(nil)

          command.call
        rescue GeoToolsOpException => e
          puts "Import failed with exception: #{e.status_code.name}"
        ensure
          data_store.dispose
        end
      end

      def run;end
    end
  end
end

