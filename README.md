geogit-ruby
===

Use GeoGit in your JRuby applications

NOTE: JRuby is required

In development: `mvn clean install` to get Java/Scala dependencies

`jruby -S rake console` or `bin/geogit_console` to open IRB with geogit loaded

Create a repo and import a shapefile:

```ruby
GeoGit.create_or_init_repo '~/Desktop/test_repo'
GeoGit.import_shapefile '~/Desktop/test_repo', '~/Desktop/states/states.shp'
```

To execute a command (get log for previously imported repo):

```ruby
include GeoGit::Command
# => Object
cmd = Log.new '~/Desktop/test_repo'
# => #<GeoGit::Command::Log:0x1d446661 @repo_path="~/Desktop/test_repo", @offset=0, @path="", @limit=0>
log = cmd.run
# => {:count=>49, :commits=>[{:id=>"b0524c80b72cf3a7a13ed1edf7114156bae95a3b", :message=>"imported_states/1", :author=>{:name=>"", :email=>""}, :committer=>{:name=>"Scooter Wadsworth", :email=>"scooterwadsworth@gmail.com"}}, {:id=>"838d69be61caffb629373ed9a44a417e5f2b1bfd", :message=>"imported_states/2", :author=>{:name=>"", :email=>""}, :committer=>{:name=>"Scooter Wadsworth", :email=>"scooterwadsworth@gmail.com"}}, ...}
```

