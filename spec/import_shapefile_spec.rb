require File.expand_path 'spec/spec_helper'
require File.expand_path 'lib/geogit'
require 'fileutils'

describe GeoGit::Command::ImportShapefile do

  before :all do
    repo_path = File.expand_path '~/geogit/test_repo'
    FileUtils.mkdir_p repo_path
    GeoGit::Command::Init.new(repo_path).run
  end

  after :all do
    FileUtils.rm_rf File.expand_path('~/geogit/test_repo')
  end

  it "should import 49 states" do
    repo_path = File.expand_path '~/geogit/test_repo'
    shp_path = File.expand_path 'spec/data/shapefile/states.shp'
    GeoGit::Command::ImportShapefile.new(repo_path, shp_path).run
    GeoGit::Command::Tree.new(repo_path, 'states').run.size.should eq 49
  end

end

