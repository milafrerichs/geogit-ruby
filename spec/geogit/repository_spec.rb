require File.expand_path 'spec/spec_helper'
require File.expand_path 'lib/geogit'

describe GeoGit::Repository do
  subject { GeoGit::Repository.new("path_to_repo") }
  let(:tree_paths) { ["d/a","d/b","d/c"] }
  let(:runnable) { double(run: true) }
  let(:geogit) { double(close: true) }
  before :each do
    subject.stub(:geogit).and_return(geogit)
  end
  context '#tree_paths' do
    let(:tree) { ["a","b","c"] }
    it "returns array of tree_paths" do
      subject.should_receive(:repo_tree_path).and_return(tree)
      subject.tree_paths("d").should eq(tree_paths)
    end
  end
  context '#add' do
    it 'collects tree_paths' do
      GeoGit::Command::FastAdd.stub(:new).and_return(runnable)
      subject.should_receive(:tree_paths).with("d").and_return(tree_paths)
      subject.add("d")
    end
    it "calls geogit command fastadd" do
      subject.stub(:tree_paths).and_return(tree_paths)
      GeoGit::Command::FastAdd.should_receive(:new).exactly(3).times.and_return(runnable)
      subject.add("d")
    end
  end
  context '#commit' do
    it 'collects tree_paths' do
      GeoGit::Command::FastCommit.stub(:new).and_return(runnable)
      subject.should_receive(:tree_paths).with("d").and_return(tree_paths)
      subject.commit("d")
    end
    it 'calls geogit command fastcommit' do
      subject.stub(:tree_paths).and_return(tree_paths)
      GeoGit::Command::FastCommit.should_receive(:new).exactly(3).times.and_return(runnable)
      subject.commit("d")
    end
  end
  context '#add_and_commit' do
    let(:trees) { ["d"] }
    it "adds and commits" do
      subject.should_receive(:repo_trees).and_return(trees)
      subject.should_receive(:add).with("d")
      subject.should_receive(:commit).with("d")
      subject.add_and_commit
    end
  end
end
