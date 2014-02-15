require File.expand_path 'spec/spec_helper'
require File.expand_path 'lib/geogit'

describe GeoGit do
  let(:tree_paths) { ["d/a","d/b","d/c"] }
  let(:runnable) { double(run: true) }
  context '.tree_paths' do
    subject { GeoGit.tree_paths("","d") }
    let(:tree) { ["a","b","c"] }
    before do
      GeoGit.stub(:repo_tree_path).and_return(tree)
    end
    it "returns array of tree_paths" do
      subject.should eq(tree_paths)
    end
  end
  context '.add' do
    subject { GeoGit.add("","",tree_paths) }
    it "fast adds" do
      GeoGit::Command::FastAdd.should_receive(:new).exactly(3).times.and_return(runnable)
      subject
    end
  end
  context '.commit' do
    subject { GeoGit.commit("","",tree_paths) }
    it 'commits' do
      GeoGit::Command::FastCommit.should_receive(:new).exactly(3).times.and_return(runnable)
      subject
    end
  end
  context '.geogit_from_repo' do
    subject { GeoGit.geogit_from_repo("") }
    let(:instancalbe) { double(instance: true) }
    it "returns a GeoGit Instance" do
      GeoGit::Instance.should_receive(:new).with("").and_return(instancalbe)
      subject
    end
  end
  context '.add_and_commit' do
    subject { GeoGit.add_and_commit("") }
    let(:trees) { ["d"] }
    let(:geogit) { double(close: true) }
    it "adds and commits" do
      GeoGit.should_receive(:geogit_from_repo).and_return(geogit)
      GeoGit.should_receive(:repo_trees).and_return(trees)
      GeoGit.should_receive(:tree_paths).and_return(tree_paths)
      GeoGit.should_receive(:add)
      GeoGit.should_receive(:commit)
      subject
    end
  end
end
