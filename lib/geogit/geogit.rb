java_import org.geogit.storage.bdbje.JEStorageModule
java_import org.geogit.storage.mongo.MongoStorageModule
java_import org.geogit.di.GeogitModule
java_import org.geogit.api.GeoGIT
java_import org.geogit.api.DefaultPlatform
java_import org.geogit.api.GeogitTransaction
java_import com.google.inject.Guice
java_import com.google.inject.util.Modules

module GeoGit
  class Instance
    attr_accessor :repo_path, :instance

    STORAGE_BACKENDS = {
      'bdbje' => JEStorageModule.new,
      'mongo' => MongoStorageModule.new
    }

    def initialize(repo_path, backend = 'bdbje')
      @repo_path = File.expand_path repo_path
      @injector = get_injector backend
      @instance = get_instance @repo_path
    end
    
    protected
    def storage_type(repo_path)
      File.open(File.join(repo_path, '.geogit', 'config')) do |f|
        f.each_line.detect {|line| line =~ /objects|staging/}.split(' ').last
      end
    end

    protected
    def get_injector(backend = nil)
      backend ||= storage_type @repo_path
      storage_module = STORAGE_BACKENDS[backend]
      Guice.create_injector Modules.override(GeogitModule.new).with(storage_module)
    end

    protected
    def get_instance(path)
      begin
        platform = DefaultPlatform.new
        platform.set_working_dir java.io.File.new(path)
        geogit = GeoGIT.new(@injector, platform.pwd)
        geogit.get_or_create_repository
        geogit
      rescue => ex
        puts ex
      end
    end

  end
end

