require 'spec_helper'

ENV['NO_PEEK_STARTUP_MESSAGE'] = 'true'

RSpec.describe "#PryRescue.peek!" do
  it "expect to open a pry in the binding of caller" do
    Pry.config.input = StringIO.new("foo = 6\nexit\n")
    Pry.config.output = StringIO.new
    foo = 5

    expect do
      PryRescue.peek!
    end.to change{ foo }.from(5).to(6)
  end

  it 'expect to include the entire call stack' do
    Pry.config.input = StringIO.new("up\nfoo = 6\nexit\n")
    Pry.config.output = StringIO.new

    def example_method
      PryRescue.peek!
    end

    foo = 5

    expect do
      PryRescue.peek!
    end.to change{ foo }.from(5).to(6)
  end
end
