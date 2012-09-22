require File.expand_path('../../lib/pry-rescue.rb', __FILE__)

describe 'Pry.rescue' do
  it 'should call PryRescue.enter_exception_context' do
    lambda{
      PryRescue.should_receive(:enter_exception_context).once
      Pry::rescue{ raise "foobar" }
    }.should raise_error(/foobar/)
  end

  it "should retry on try-again" do
    @called = 0
    PryRescue.should_receive(:enter_exception_context).once{ throw :try_again }
    Pry::rescue do
      @called += 1
      raise "foobar" if @called == 1
    end
    @called.should == 2
  end

  it "should try-again from innermost block" do
    @outer = @inner = 0
    PryRescue.should_receive(:enter_exception_context).once{ throw :try_again }
    Pry::rescue do
      @outer += 1
      Pry::rescue do
        @inner += 1
        raise "oops" if @inner == 1
      end
    end

    @outer.should == 1
    @inner.should == 2
  end

  it "should clear out exceptions between retrys at the same level" do
    @outer = @inner = 0
    PryRescue.should_receive(:enter_exception_context).once{ |raised| raised.size.should == 1; throw :try_again }
    PryRescue.should_receive(:enter_exception_context).once{ |raised| raised.size.should == 1; throw :try_again }
    Pry::rescue do
      @outer += 1
      Pry::rescue do
        @inner += 1
        raise "oops" if @inner <= 2
      end
    end
  end

  it "should clear out exceptions between retrys at a higher level" do
    @outer = @inner = 0
    PryRescue.should_receive(:enter_exception_context).once{ |raised| raised.size.should == 1; throw :try_again }
    PryRescue.should_receive(:enter_exception_context).once{ |raised| raised.size.should == 1; throw :try_again }
    PryRescue.should_receive(:enter_exception_context).once{ |raised| raised.size.should == 1; throw :try_again }
    Pry::rescue do
      @outer += 1
      Pry::rescue do
        @inner += 1
        raise "oops" if @inner <= 2
      end
      raise "foops" if @outer == 1
    end
  end
end

describe "Pry.rescued" do

  it "should raise an error if used outwith Pry::rescue" do
    begin
      raise "foo"
    rescue => e
      lambda{
        Pry.rescued(e)
      }.should raise_error(/Pry::rescue/)
    end
  end

  it "should raise an error if used on an exception not raised" do
    Pry::rescue do
      lambda{
        Pry.rescued(RuntimeError.new("foo").exception)
      }.should raise_error(/not raised/)
    end
  end

  it "should call Pry.enter_exception_context" do
    Pry::rescue do
      begin
        raise "foo"
      rescue => e
        PryRescue.should_receive(:enter_exception_context).once
        Pry::rescued(e)
      end
    end
  end
end

