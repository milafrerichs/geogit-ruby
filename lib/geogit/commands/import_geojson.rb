java_import org.geogit.geotools.plumbing.ImportOp
java_import org.geogit.geotools.plumbing.GeoToolsOpException
java_import org.geotools.data.DataStore
java_import org.geotools.geojson.feature.FeatureJSON
java_import org.geotools.data.memory.MemoryDataStore
java_import java.io.IOException
java_import java.io.FileInputStream
java_import java.io.ByteArrayInputStream

JFile ||= java.io.File

module GeoGit
  module Command
    class ImportGeoJSON < GenericCommand
      def initialize(repo_path, geojson)
        @repo_path = repo_path
        @geojson = File.exist?(File.expand_path(geojson)) ? read_geojson(geojson) : geojson
      end

      def read_geojson(geojson_file)
        #IO.read File.expand_path(geojson_file)
        f = JFile.new File.expand_path(geojson_file)
        FileInputStream.new f
      end

      def get_data_store(geojson)
        input_stream = case geojson
                       when String
                         ByteArrayInputStream.new geojson.to_java_bytes
                       when Java::JavaIo::FileInputStream
                         geojson
                       end

        feature_collection = FeatureJSON.new.read_feature_collection input_stream
        MemoryDataStore.new feature_collection
      end

      def run
        geogit = GeoGit::Instance.new(@repo_path).instance
        
        data_store = get_data_store @geojson

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
      ensure
        geogit.close
      end
    end
  end
end

