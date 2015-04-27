require 'spec_helper'

RSpec.describe "PryRescue.load" do
  if defined?(PryStackExplorer)
    it "expect to open at the correct point" do
      expect(PryRescue).to receive(:pry).once do |opts|
       expect(opts[:call_stack].first.eval("__FILE__")).to end_with('spec/fixtures/simple.rb')
      end

      expect do
        PryRescue.load("spec/fixtures/simple.rb")
      end.to raise_error(/simple-exception/)
    end

    it "expect open above the standard library" do
      expect(PryRescue).to receive(:pry).once do |opts|
        expect(opts[:call_stack][opts[:initial_frame]].eval("__FILE__")).to end_with('spec/fixtures/uri.rb')
      end

      expect do
        PryRescue.load("spec/fixtures/uri.rb")
      end.to raise_error(URI::InvalidURIError)
    end

    it "expect to keep the standard library on the binding stack" do
      expect(PryRescue).to receive(:pry).once do |opts|
        expect(opts[:call_stack].first.eval("__FILE__")).to start_with(RbConfig::CONFIG['libdir'])
      end

     expect do 
        PryRescue.load("spec/fixtures/uri.rb")
     end.to raise_error(URI::InvalidURIError)
    end

    it "expect to open above gems" do
      expect(PryRescue).to receive(:pry).once do |opts|
        expect(opts[:call_stack][opts[:initial_frame]].eval("__FILE__")).to end_with('spec/fixtures/coderay.rb')
      end

      expect do
        PryRescue.load("spec/fixtures/coderay.rb")
      end.to raise_error(ArgumentError)
    end

    it "expect to open above gems" do
      expect(PryRescue).to receive(:pry).once do |opts|
        coderay_path = Gem::Specification.respond_to?(:detect) ?
                         Gem::Specification.detect{|x| x.name == 'coderay' }.full_gem_path :
                         Gem.all_load_paths.grep(/coderay/).last

        expect(opts[:call_stack].first.eval("__FILE__")).to start_with(coderay_path)
      end

      expect do 
        PryRescue.load("spec/fixtures/coderay.rb")
      end.to raise_error(ArgumentError)
    end

    it "expect to skip pwd, even if it is a gem (but not vendor stuff)" do
      allow(Gem::Specification).to receive(:any?).and_return(true)
      expect(PryRescue.send(:user_path?, Dir.pwd + '/asdf.rb')).to be_truthy
      expect(PryRescue.send(:user_path?, Dir.pwd + '/vendor/asdf.rb')).to be_falsey
    end

    it "expect to filter out duplicate stack frames" do
      expect(PryRescue).to receive(:pry).once do |opts|
        expect(opts[:call_stack][0].eval("__LINE__")).to eq(4)
        expect(opts[:call_stack][1].eval("__LINE__")).to eq(12)
      end

      expect do 
        PryRescue.load("spec/fixtures/super.rb")
      end.to raise_error(/super-exception/)
    end

    it "expect calculate correct initial frame even when duplicates are present" do
      expect(PryRescue).to receive(:pry).once do |opts|
        expect(opts[:call_stack][0].eval("__FILE__")).to end_with('fake.rb')
        expect(opts[:call_stack][opts[:initial_frame]].eval("__FILE__")).to end_with('spec/fixtures/initial.rb')
      end

      expect do
        PryRescue.load("spec/fixtures/initial.rb")
      end.to raise_error(/no :baz please/)
    end

    it "expect to skip over reraises from within gems" do
      expect(PryRescue).to receive(:pry).once do |opts|
        expect(opts[:call_stack][0].eval("__FILE__")).to end_with('spec/fixtures/reraise.rb')
      end

      expect do
        PryRescue.load("spec/fixtures/reraise.rb")
      end.to raise_error(/reraise-exception/)
    end

    it "expect to not skip over independent raises within gems" do
      expect(PryRescue).to receive(:pry).once do |opts|
        expect(opts[:call_stack][0].eval("__FILE__")).to end_with('fake.rb')
      end

      expect do 
        PryRescue.load("spec/fixtures/raiseother.rb")
      end.to raise_error(/raiseother_exception/)
    end

    it "expect output a warning if the exception was not raised" do
      expect(PryRescue).to_not receive(:enter_exception_context)
      expect(Pry).to receive(:warn).once
      Pry.rescued(RuntimeError.new("foo"))
    end
  else
    it "expect to open at the correct point" do
      expect(Pry).to receive(:start).once do |binding, h|
        expect(binding.eval("__FILE__")).to end_with('spec/fixtures/simple.rb')
      end 

      expect do 
        PryRescue.load("spec/fixtures/simple.rb")
      end.to raise_error(/simple-exception/)
    end
  end
end
