$:.unshift File.expand_path('../lib', __FILE__)
require 'geogit/version'

task :build do
  system 'gem build geogit.gemspec'
end

task :release => :build do
  system "gem push geogit-#{GeoGit::VERSION}.gem"
end

task :console do
  ARGV.clear
  require File.expand_path(File.join(File.dirname(__FILE__), 'lib', 'geogit'))
  require 'irb'
  IRB.start
end

