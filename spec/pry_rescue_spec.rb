require File.expand_path('../../lib/pry-rescue.rb', __FILE__)
require 'uri'

describe "PryRescue.load" do
  before :all do
    if !binding.respond_to?(:source_location)
      Binding.define_method :source_location do
        PryRescue::SourceLocation.call(self)
      end
    end
  end

  if defined?(PryStackExplorer)
    it "should open at the correct point" do
      expect(PryRescue).to receive(:pry).once { |opts|
        expect(opts[:call_stack].first.source_location[0]).to end_with('spec/fixtures/simple.rb')
      }
      expect(lambda {
        PryRescue.load("spec/fixtures/simple.rb")
      }).to raise_error(/simple-exception/)
    end

    it "should open above the standard library" do
      expect(PryRescue).to receive(:pry).once do |opts|
        expect(opts[:call_stack][opts[:initial_frame]].source_location[0]).to end_with('spec/fixtures/uri.rb')
      end
      expect(lambda{
        PryRescue.load("spec/fixtures/uri.rb")
      }).to raise_error(URI::InvalidURIError)
    end

    it "should keep the standard library on the binding stack" do
      expect(PryRescue).to receive(:pry).once do |opts|
        expect(opts[:call_stack].first.source_location[0]).to start_with(RbConfig::CONFIG['libdir'])
      end
      expect(lambda{
        PryRescue.load("spec/fixtures/uri.rb")
      }).to raise_error(URI::InvalidURIError)
    end

    it "should open above gems" do
      expect(PryRescue).to receive(:pry).once do |opts|
        expect(opts[:call_stack][opts[:initial_frame]].source_location[0]).to end_with('spec/fixtures/coderay.rb')
      end
      expect(lambda{
        PryRescue.load("spec/fixtures/coderay.rb")
      }).to raise_error(ArgumentError)
    end

    it "should open above gems" do
      expect(PryRescue).to receive(:pry).once do |opts|
        coderay_path = Gem::Specification.respond_to?(:detect) ?
                         Gem::Specification.detect{|x| x.name == 'coderay' }.full_gem_path :
                         Gem.all_load_paths.grep(/coderay/).last

        expect(opts[:call_stack].first.source_location[0]).to start_with(coderay_path)
      end
      expect(lambda{
        PryRescue.load("spec/fixtures/coderay.rb")
      }).to raise_error(ArgumentError)
    end

    it "should skip pwd, even if it is a gem (but not vendor stuff)" do
      # Gem::Specification.stub :any? do true end
      allow(Gem::Specification).to receive(:any?).and_return(true)

      expect(
        PryRescue.send(:user_path?, Dir.pwd + '/asdf.rb')
      ).to be true

      expect(
        PryRescue.send(:user_path?, Dir.pwd + '/vendor/asdf.rb')
      ).to be false
    end

    it "should filter out duplicate stack frames" do
      expect(PryRescue).to receive(:pry).once do |opts|
        expect(opts[:call_stack][0].source_location[1]).to be(4)
        expect(opts[:call_stack][1].source_location[1]).to be(12)
      end
      expect(lambda{
        PryRescue.load("spec/fixtures/super.rb")
      }).to raise_error(/super-exception/)
    end

    it "should calculate correct initial frame even when duplicates are present" do
      expect(PryRescue).to receive(:pry).once do |opts|
        expect(opts[:call_stack][0].source_location[0]).to end_with('fake.rb')
        expect(opts[:call_stack][opts[:initial_frame]].source_location[0]).to end_with('spec/fixtures/initial.rb')
      end
      expect(lambda{
        PryRescue.load("spec/fixtures/initial.rb")
      }).to raise_error(/no :baz please/)
    end

    it "should skip over reraises from within gems" do
      expect(PryRescue).to receive(:pry).once do |opts|
        expect(opts[:call_stack][0].source_location[0]).to end_with('spec/fixtures/reraise.rb')
      end
      expect(lambda{
        PryRescue.load("spec/fixtures/reraise.rb")
      }).to raise_error(/reraise-exception/)
    end

    it "should not skip over independent raises within gems" do
      expect(PryRescue).to receive(:pry).once do |opts|
        expect(opts[:call_stack][0].source_location[0]).to end_with('fake.rb')
      end
      expect(lambda{
        PryRescue.load("spec/fixtures/raiseother.rb")
      }).to raise_error(/raiseother_exception/)
    end

    it "should output a warning if the exception was not raised" do
      expect(PryRescue).to_not receive(:enter_exception_context)
      expect(Pry).to receive(:warn).once
      Pry.rescued(RuntimeError.new("foo"))
    end
  else
    it "should open at the correct point" do
      expect(Pry).to receive(:start).once { |binding, h|
        expect(binding.source_location[0]).to end_with('spec/fixtures/simple.rb')
      }
      expect(lambda{
        PryRescue.load("spec/fixtures/simple.rb")
      }).to raise_error(/simple-exception/)
    end
  end
end
