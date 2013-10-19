java_import org.geogit.api.GlobalInjectorBuilder
java_import org.geogit.storage.bdbje.JEStorageModule
java_import org.geogit.storage.neo4j.Neo4JModule
java_import org.geogit.di.GeogitModule
java_import org.geogit.api.GeoGIT
java_import org.geogit.api.DefaultPlatform

module GeoGit
  class << self
    def setup_geogit
      geogit_module = GeogitModule.new
      je_storage_module = JEStorageModule.new
      neo4j_module = Neo4JModule.new
      GlobalInjectorBuilder.builder.build_with_overrides je_storage_module, neo4j_module
    end

    def get_instance(path)
      begin
        platform = DefaultPlatform.new
        platform.set_working_dir java.io.File.new(path)
        geogit = GeoGIT.new(setup_geogit, platform.pwd)
        geogit.get_or_create_repository
        geogit
      rescue => ex
        puts ex
      end
    end
  end
end

