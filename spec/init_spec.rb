require File.expand_path 'spec/spec_helper'
require File.expand_path 'lib/geogit'
require 'fileutils'

describe GeoGit::Command::Init do

  before :all do
    FileUtils.mkdir_p File.expand_path('~/geogit/test_repo')
  end

  after :all do
    FileUtils.rm_rf File.expand_path('~/geogit/test_repo')
  end

  it "should create empty repo" do
    repo_path = File.expand_path('~/geogit/test_repo')
    geogit = GeoGit::Instance.new(repo_path).instance
    GeoGit::Command::Init.new(geogit, repo_path).run
    Dir.exist?(File.join(repo_path, '.geogit')).should be_true
  end

end

