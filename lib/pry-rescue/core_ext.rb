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
    return yield if @raised
    @raised = []

    Interception.listen(block) do |exception, binding|
      if defined?(PryStackExplorer)
        @raised << [exception, binding.callers]
      else
        @raised << [exception, Array(binding)]
      end
    end

  rescue Exception => e
    case PryRescue.enter_exception_context(@raised)
    when :try_again
      retry
    else
      raise
    end
  ensure
    @raised = nil
  end

  # Start a pry session on an exception that you rescued within a Pry::rescue{ }.
  #
  # @example
  #   Pry::rescue do
  #     begin
  #       raise "foo"
  #     rescue => e
  #       Pry::rescued(e)
  #     end
  #   end
  #
  # TODO: You cannot use the 'try-again' command with Pry::rescued.
  def self.rescued(e)
    raise "Tried to inspect rescued exception outside Pry::rescue{ } block" unless @raised

    raised = @raised.dup
    raised.pop until raised.empty? || raised.last.first == e
    raise "Tried to inspect an exception that was not raised" unless raised.any?

    while PryRescue.enter_exception_context(raised) == :try_again
      puts "Cannot try again from a rescued exception!"
    end
  end
end
