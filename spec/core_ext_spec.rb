require 'spec_helper'

RSpec.describe '#Pry.rescue' do
  it 'expect to call PryRescue.enter_exception_context' do
    expect {
      expect(PryRescue).to receive(:enter_exception_context).once
      Pry::rescue{ raise "foobar" }
    }.to raise_error(/foobar/)
  end

  it "expect to retry on try-again" do
    called = 0
    expect(PryRescue).to receive(:enter_exception_context).once{ throw :try_again }
    Pry::rescue do
      called += 1
      raise "foobar" if called == 1
    end
    expect(called).to eq(2)
  end

  it "expect to try-again from innermost block" do
    outer = inner = 0
    expect(PryRescue).to receive(:enter_exception_context).once{ throw :try_again }
    Pry::rescue do
      outer += 1
      Pry::rescue do
        inner += 1
        raise "oops" if inner == 1
      end
    end

    expect(outer).to eq(1)
    expect(inner).to eq(2)
  end

  it "expect to enter the first occurence of an exception that is re-raised" do
    expect(PryRescue).to receive(:enter_exception_context) do |raised|
      expect(raised.size).to eq(1)
    end

    expect do
      Pry::rescue do
        begin
          raise "first_occurance"
        rescue => e
          raise
        end
      end
    end.to raise_error(/first_occurance/)
  end

  it "expect to not catch SystemExit" do
    expect(PryRescue).to_not receive(:enter_exception_context)

    expect do
      Pry::rescue do
        exit
      end
    end.to raise_error SystemExit
  end

  it 'expect to not catch Ctrl+C' do
    expect(PryRescue).to_not receive(:enter_exception_context)

    expect do
      Pry::rescue do
        raise Interrupt, "ctrl+c (fake)"
      end
    end.to raise_error Interrupt
  end
end

RSpec.describe "Pry.rescued" do

  it "expect to raise an error if used outwith Pry::rescue" do
    begin
      raise "foo"
    rescue => e
      expect(Pry).to receive(:warn)
      Pry.rescued(e)
    end
  end

  it "expect to raise an error if used on an exception not raised" do
    Pry::rescue do
      expect(Pry).to receive(:warn) do |message|
        expect(message).to match(/^WARNING: Tried to inspect exception outside of Pry::rescue/)
      end
      Pry.rescued(RuntimeError.new("foo").exception)
    end
  end

  it "expect to call Pry.enter_exception_context" do
    Pry::rescue do
      begin
        raise "foo"
      rescue => e
        expect(PryRescue).to receive(:enter_exception_context)
        Pry::rescued(e)
      end
    end
  end
end

