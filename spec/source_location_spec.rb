describe PryRescue::SourceLocation do
  describe ".call" do
    subject{ described_class.call(binding) }

    it "matches [file, line]" do
      is_expected.to match([__FILE__, be_between(2,30)])
    end
  end

  it "will be removed when Ruby 2.5 is EOL" do
    time = Time.now

    if time >= described_class::DEPRECATION_TIME
      expect(
        defined?(PryRescue::SourceLocation)
      ).to be false
    end
  end
end
