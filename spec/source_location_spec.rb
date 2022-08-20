describe 'PryRescue::SourceLocation' do
  if RUBY_VERSION < "2.6.0"
    require 'pry-rescue/source_location'

    subject { binding.source_location }

    it 'matches [file, line]' do
      is_expected.to match([__FILE__, be_between(2, 30)])
    end
  else
    it 'will be removed when Ruby 2.5 is EOL' do
      expect(
        defined?(PryRescue::SourceLocation)
      ).to be_falsey
    end

    it 'should raise an error when people upgrade' do
      expect {
        require 'pry-rescue/source_location'
      }.to raise_error(RuntimeError, /source_location exists by default in Ruby 2.6/)

      expect(defined?(PryRescue::SourceLocation)).to be_falsey
    end
  end
end
