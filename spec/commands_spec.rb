require './spec/spec_helper'

describe "pry-rescue commands" do
  describe "try-again" do
    it "should throw try_again" do
      PryRescue.should_receive(:in_exception_context?).and_return{ true }

      lambda{
        Pry.new.process_command "try-again", '', TOPLEVEL_BINDING
      }.should throw_symbol :try_again
    end

    it "should raise a CommandError if not in Pry::rescue" do
      PryRescue.should_receive(:in_exception_context?).and_return{ false }

      lambda{
        Pry.new.process_command "try-again", '', TOPLEVEL_BINDING
      }.should raise_error Pry::CommandError
    end
  end

  describe "cd-cause" do
    it "should enter the context of an explicit exception" do
      begin
        b1 = binding
        raise "original"
      rescue => e1
        b2 = binding
      end

      Pry.should_receive(:rescued).once.with{ |raised|
        raised.should == e1
      }

      Pry.new.process_command 'cd-cause e1', '', binding
    end

    it "should enter the context of _ex_ if no exception is given" do
      begin
        b1 = binding
        raise "original"
      rescue => _ex_
        b2 = binding
      end

      Pry.should_receive(:rescued).once.with{ |raised|
        raised.should == _ex_
      }

      Pry.new.process_command 'cd-cause', '', binding
    end
  end

  describe "cd-cause" do
    it "should enter the next exception's context" do
      begin
        begin
          b1 = binding
          raise "original"
        rescue => e1
          b2 = binding
          raise # similar to dubious re-raises you'll find in the wild
        end
      rescue => e2
        # Hacks due to us not really entering a pry session here
        _raised_ = [[e1, [b1]], [e2, [b2]]]
        _ex_ = e2
      end

      PryRescue.should_receive(:enter_exception_context).once.with{ |raised|
        raised.should == [[e1, [b1]]]
      }

      Pry.new.process_command 'cd-cause', '', binding
    end

    it "should raise a CommandError if no previous commands" do
      begin
        b1 = binding
        raise "original"
      rescue => e1
        _raised_ = [[e1, [b1]]]
      end

      lambda{
        Pry.new.process_command 'cd-cause', '', binding
      }.should raise_error Pry::CommandError, /No previous exception/
    end

    it "should raise a CommandError if not in Pry::rescue" do
      lambda{
        Pry.new.process_command 'cd-cause', '', binding
      }.should raise_error Pry::CommandError, /No previous exception/
    end
  end
end
