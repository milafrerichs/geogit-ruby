geogit-ruby
===

Use GeoGit in your JRuby applications

NOTE: JRuby is required

In development: `mvn clean install` to get Java/Scala dependencies

`jruby -S rake console` or `bin/geogit_console` to open IRB with geogit loaded

To execute a command:

```ruby
include GeoGit::Command
# => Object
cmd = Log.new '/path/to/geogit/repo'
# => #<GeoGit::Command::Log:0x1d446661 @repo_path="/path/to/geogit/repo", @offset=0, @path="", @limit=0>
log = cmd.run
# => {:count=>1, :commits=>[{:id=>"427be03bb96796970f2713cce4be7f6748fd4619", :message=>"Initial commit", :author=>{:name=>"Example User", :email=>"example@example.org"}, :committer=>{:name=>"Example User", :email=>"example@example.org"}}]}
```

