require File.expand_path 'spec/spec_helper'
require File.expand_path 'lib/geogit'
require 'fileutils'

describe GeoGit::Command::ImportGeoJSON do

  before :all do
    repo_path = File.expand_path '~/geogit/test_repo'
    FileUtils.mkdir_p repo_path
    GeoGit::Repository.new(repo_path).create_or_init
  end

  after :all do
    FileUtils.rm_rf File.expand_path('~/geogit/test_repo')
  end

  it "should import hurricanes" do
    repo_path = File.expand_path '~/geogit/test_repo'
    geojson_path = File.expand_path 'spec/data/geojson/fl_2004_hurricanes.geojson'
    GeoGit::Command::ImportGeoJSON.new(repo_path, geojson_path).run
    GeoGit::Command::Tree.new(repo_path, 'feature').run.size.should eq 652
  end

end

