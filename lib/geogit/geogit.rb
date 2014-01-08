java_import org.geogit.storage.bdbje.JEStorageModule
java_import org.geogit.storage.neo4j.Neo4JModule
java_import org.geogit.di.GeogitModule
java_import org.geogit.api.GeoGIT
java_import org.geogit.api.DefaultPlatform
java_import org.geogit.api.GeogitTransaction
java_import com.google.inject.Guice
java_import com.google.inject.util.Modules

module GeoGit
  class Instance
    attr_accessor :repo_path, :instance

    def initialize(repo_path)
      @repo_path = File.expand_path repo_path
      @injector = get_injector
      @instance = get_instance @repo_path
    end
    
    def get_command_locator(transaction_id = nil)
      unless transaction_id.nil?
        GeoGitTransaction.new(
          @instance.get_command_locator,
          @instance.get_repository,
          transaction_id
        )
      else
        @instance.get_command_locator
      end
    end

    protected
    def get_injector
      je_storage_module = JEStorageModule.new
      Guice.create_injector Modules.override(GeogitModule.new).with(je_storage_module)
    end

    protected
    def get_instance(path)
      begin
        platform = DefaultPlatform.new
        platform.set_working_dir java.io.File.new(path)
        geogit = GeoGIT.new(get_injector, platform.pwd)
        geogit.get_or_create_repository
        geogit
      rescue => ex
        puts ex
      end
    end

  end
end

