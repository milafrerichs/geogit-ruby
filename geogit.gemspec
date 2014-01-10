# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'geogit/version'

Gem::Specification.new do |gem|
  gem.name = 'geogit'
  gem.version = GeoGit::VERSION
  gem.platform = 'java'
  gem.description = 'GeoGit Utility Library for JRuby'
  gem.summary = 'Use GeoGit with JRuby'
  gem.licenses = ['MIT']

  gem.authors = ['Scooter Wadsworth']
  gem.email = ['scooterwadsworth@gmail.com']
  gem.homepage = 'https://github.com/scooterw/geogit-ruby'

  gem.required_ruby_version = '>= 1.9.2'
  gem.required_rubygems_version = '>= 1.3.6'

  gem.files = Dir['README.md', 'bin/**/*', 'lib/**/*']
  gem.require_paths = ['lib']
  gem.bindir = 'bin'
  gem.executables = ['geogit_console']

  gem.add_dependency 'multi_json', '~> 1.8.0'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'simplecov'
end

