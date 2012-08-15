class Pry

  # Start a pry session on any unhandled exceptions within this block.
  #
  # @example
  #   Pry::rescue do
  #     raise "foo"
  #   end
  #
  # @return [Object] The return value of the block
  def self.rescue(&block)
    raised = []

    Interception.listen(block) do |exception, binding|
      if defined?(PryStackExplorer)
        raised << [exception, binding.callers]
      else
        raised << [exception, Array(binding)]
      end
    end

  rescue Exception => e
    case PryRescue.enter_exception_context(raised)
    when :try_again
      retry
    else
      raise
    end
  end
end
