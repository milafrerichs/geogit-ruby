java_import org.geogit.geotools.plumbing.ImportOp
java_import org.geogit.geotools.plumbing.GeoToolsOpException
java_import org.geotools.data.DataStore
java_import org.geotools.data.shapefile.ShapefileDataStoreFactory
java_import java.io.IOException

JFile ||= java.io.File
JBoolean ||= java.lang.Boolean

module GeoGit
  module Command
    class ImportShapefile < GenericCommand
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
        geogit = GeoGit::Instance.new(@repo_path).instance

        @shapefiles.each do |shp_path|
          data_store = get_data_store File.expand_path(shp_path)

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
      ensure
        geogit.close
      end
    end
  end
end

