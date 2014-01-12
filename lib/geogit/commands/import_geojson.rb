java_import org.geotools.geojson.feature.FeatureJSON
java_import org.geotools.data.memory.MemoryDataStore
java_import java.io.FileInputStream
java_import java.io.ByteArrayInputStream

JFile ||= java.io.File

module GeoGit
  module Command
    class ImportGeoJSON < ImportCommand
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
                       when FileInputStream
                         geojson
                       end

        feature_collection = FeatureJSON.new.read_feature_collection input_stream
        MemoryDataStore.new feature_collection
      end

      def run
        geogit = get_geogit_instance
        do_import(geogit, @geojson)
      ensure
        geogit.close
      end
    end
  end
end

