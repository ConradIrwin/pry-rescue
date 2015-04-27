require 'spec_helper'

RSpec.describe "pry-rescue commands" do
  describe "#try-again" do
    it "expect to throw try_again" do
      expect(PryRescue).to receive(:in_exception_context?).and_return(true)

      expect( lambda{ Pry.new.process_command "try-again TOPLEVEL_BINDING" } ).to throw_symbol :try_again
    end

    it "expect to raise a CommandError if not in Pry::rescue" do
      # expect(PryRescue).to receive(:in_exception_context?).and_return(false)
      allow(PryRescue).to receive(:in_exception_context?).and_return(false)

       expect{ Pry.new.process_command "try-again TOPLEVEL_BINDING" }.to raise_error Pry::CommandError
    end
  end

  describe "#cd-cause" do
    it "expect to not enter the context of an explicit exception" do
      begin
        b1 = binding
        raise "original"
      rescue => ErrorOne
        b2 = binding
      end

      expect(Pry).to receive(:rescued) do |raised|
        expect(raised).to eq(ErrorOne)
      end

      Pry.new.process_command 'cd-cause ErrorOne binding'
    end

    context "when no exception is given" do
      it "expect to enter the context of _ex_"  do
        b2 = nil
        _ex_ = nil
        Pry::rescue do
          begin
            b1 = binding
            raise "original"
          rescue => ErrorOne
            b2 = binding
          end
        end

        expect(Pry).to receive(:rescued) do |raised|
          expect(raised).to eq(ErrorOne)
        end

        Pry.new.process_command 'cd-cause ErrorOne binding'
      end
    end

    context "when it has nested exceptions" do
      it "expect to enter the next exception's context" do
        _ex_ = nil
        e1 = nil
        Pry::rescue do
          begin
            begin
              b1 = binding
              raise "original"
            rescue => DeepException
              b2 = binding
              raise # similar to dubious re-raises you'll find in the wild
            end
          rescue => ErrorOne
            _ex_ = ErrorOne
          end
        end

        expect(PryRescue).to receive(:enter_exception_context) do |raised|
          expect(raised).to eq(DeepException)
        end

        Pry.new.process_command 'cd-cause DeepException binding'
      end
    end

    context "when there are no previous commands" do
      it "expect to raise a CommandError" do
        begin
          b1 = binding
          raise "original"
        rescue => ErrorOne
          # Hacks due to us not really entering a pry session here
          _rescued_ = ErrorOne
          _ex_ = ErrorOne
        end

        expect {
          Pry.new.process_command 'cd-cause'
        }.to raise_error Pry::CommandError, /No previous exception/
      end
    end

    context "when a re-raise occurs" do
      it "expect to raise a CommandError" do
        _ex_ = nil
        Pry::rescue do
          begin
            begin
              raise "oops"
            rescue => e
              raise e
            end
          rescue => _ex_
          end
        end
        _rescued_ = _ex_

        expect {
          Pry.new.process_command 'cd-cause'
        }.to raise_error Pry::CommandError, /No previous exception/
      end
    end

    context "when not in Pry::rescue" do
      it "should raise CommandError" do
        expect {
          Pry.new.process_command 'cd-cause'
        }.to raise_error Pry::CommandError, /No previous exception/
      end
    end
  end
end
