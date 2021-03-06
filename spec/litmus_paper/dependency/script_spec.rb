require 'spec_helper'

describe LitmusPaper::Dependency::Script do
  describe "#available?" do
    it "is true when the script returns 0" do
      check = LitmusPaper::Dependency::Script.new("true")
      check.should be_available
    end

    it "is false when the script returns 1" do
      check = LitmusPaper::Dependency::Script.new("false")
      check.should_not be_available
    end

    it "is false when the script exceeds the timeout" do
      check = LitmusPaper::Dependency::Script.new("sleep 10", :timeout => 1)
      check.should_not be_available
    end

    it "kills the child process when script check exceeds timeout" do
      check = LitmusPaper::Dependency::Script.new("sleep 50", :timeout => 1)
      check.should_not be_available
      expect { Process.kill(0, check.script_pid) }.to raise_error(Errno::ESRCH)
    end

    it "can handle pipes" do
      check = LitmusPaper::Dependency::Script.new("ls | grep lib")
      check.should be_available

      check = LitmusPaper::Dependency::Script.new("ls | grep missing")
      check.should_not be_available
    end

    it "logs exceptions and returns false" do
      check = LitmusPaper::Dependency::Script.new("command_not_found")
      LitmusPaper.logger.should_receive(:info)
      check.should_not be_available
    end
  end

  describe "to_s" do
    it "returns the command" do
      check = LitmusPaper::Dependency::Script.new("sleep 10")
      check.to_s.should == "Dependency::Script(sleep 10)"
    end
  end
end
