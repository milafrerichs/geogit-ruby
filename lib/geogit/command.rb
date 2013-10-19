java_import org.geogit.api.CommandLocator
java_import org.geogit.api.GeogitTransaction
java_import java.io.File
java_import java.util.UUID

module GeoGit
  class Command
    def initialize;end

    # RELEASE REFERENCE TO GEOGIT AFTER OP
    def self.get_command_locator(geogit, transaction_id=nil)
      unless transaction_id.nil?
        GeogitTransaction.new(geogit.get_command_locator, geogit.get_repository, transaction_id)
      else
        geogit.get_command_locator
      end
    end
  end
end

