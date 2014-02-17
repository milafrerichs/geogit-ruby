require File.expand_path 'spec/spec_helper'
require File.expand_path 'lib/geogit'

describe GeoGit do
  subject { GeoGit.add_and_commit("path_to_repo") }
  it "creates a new geogit repo" do
    repo = double(add_and_commit: true)
    GeoGit::Repository.stub(:add_and_commit)
    GeoGit::Repository.should_receive(:new).with("path_to_repo").and_return(repo)
    subject
  end
  it "calls add_and_commit" do
    GeoGit::Repository.any_instance.should_receive(:add_and_commit)
    subject
  end
end
