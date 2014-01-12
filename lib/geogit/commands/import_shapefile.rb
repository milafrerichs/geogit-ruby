java_import org.geotools.data.shapefile.ShapefileDataStoreFactory
java_import java.io.IOException

JFile ||= java.io.File
JBoolean ||= java.lang.Boolean

module GeoGit
  module Command
    class ImportShapefile < ImportCommand
      def initialize(repo_path, *shapefiles)
        @repo_path = repo_path
        @shapefiles = shapefiles
      end

      def get_data_store(shp_path)
        return nil unless File.exist? shp_path

        begin
          params = {
            ShapefileDataStoreFactory::URLP.key => JFile.new(shp_path).toURI.toURL,
            ShapefileDataStoreFactory::NAMESPACEP.key => 'http://www.opengis.net/gml',
            ShapefileDataStoreFactory::CREATE_SPATIAL_INDEX.key => JBoolean::FALSE,
            ShapefileDataStoreFactory::ENABLE_SPATIAL_INDEX.key => JBoolean::FALSE,
            ShapefileDataStoreFactory::MEMORY_MAPPED.key => JBoolean::FALSE
          }.to_java

          ShapefileDataStoreFactory.new.create_data_store params
        rescue IOException => e
          puts e
          nil
        end
      end

      def run
        geogit = get_geogit_instance

        @shapefiles.each do |shp_path|
          do_import(geogit, File.expand_path(shp_path))
        end
      ensure
        geogit.close
      end
    end
  end
end

