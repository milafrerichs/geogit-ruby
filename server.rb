require 'sinatra'
require 'multi_json'

require 'lib/geogit'

module GeoGit
  class Server < Sinatra::Base
    get '/' do
      content_type :json
      MultiJson.dump({name: 'Scooter', message: 'Hi'})
    end
  end
end
