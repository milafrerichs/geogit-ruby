java_import org.geotools.geojson.feature.FeatureJSON
java_import org.geotools.data.memory.MemoryDataStore
java_import java.io.FileInputStream
java_import java.io.ByteArrayInputStream

JFile ||= java.io.File

module GeoGit
  module Command
    class ImportGeoJSON < ImportCommand
      def initialize(repo_path, geojson, fid_attribute = nil)
        @repo_path = repo_path
        @geojson = geojson_to_input_stream geojson
        @fid_attribute = fid_attribute
      end

      def geojson_to_input_stream(geojson)
        case geojson
        when String
          geojson_path = File.expand_path(geojson)

          raise RuntimeError.new('GeoJSON file does not exist') unless File.exist?(geojson_path)

          FileInputStream.new JFile.new(geojson_path)
        when ByteArrayInputStream
          geojson
        when FileInputStream
          geojson
        end
      end

      def get_data_store(geojson)
        #input_stream = case geojson
        #               when String
        #                 ByteArrayInputStream.new geojson.to_java_bytes
        #               when ByteArrayInputStream
        #                 geojson
        #               when FileInputStream
        #                 geojson
        #               end

        feature_collection = FeatureJSON.new.read_feature_collection geojson
        MemoryDataStore.new feature_collection
      end

      def run
        geogit = get_geogit_instance
        do_import(geogit, @geojson, @fid_attribute)
      ensure
        geogit.close
      end
    end
  end
end

