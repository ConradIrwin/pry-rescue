class Pry

  # Start a pry session on any unhandled exceptions within this block.
  #
  # @example
  #   Pry::capture do
  #     raise "foo"
  #   end
  #
  # @return [Object] The return value of the block
  def self.capture(&block)
    raised = []

    Interception.listen(block) do |exception, binding|
      if defined?(PryStackExplorer)
        raised << [exception, binding.callers]
      else
        raised << [exception, Array(binding)]
      end
    end

  rescue Exception => e
    PryCapture.enter_exception_context(raised)
    raise
  end
end
