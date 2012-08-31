# Additional methods provided by pry-rescue.
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
    (@raised_stack ||= []) << raised

    loop do
      catch(:try_again) do
        raised.clear
        begin
          return Interception.listen(block) do |exception, binding|
                    if defined?(PryStackExplorer)
                      raised << [exception, binding.callers]
                    else
                      raised << [exception, Array(binding)]
                    end
                  end
        rescue Exception => e
          PryRescue.enter_exception_context(raised)
          raise e
        end
      end
    end
  ensure
    @raised_stack.pop
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
  def self.rescued(e=$!)
    raise "Tried to inspect rescued exception outside Pry::rescue{ } block" unless @raised_stack.any?

    raised = @raised_stack.last.dup
    raised.pop until raised.empty? || raised.last.first == e
    raise "Tried to inspect an exception that was not raised in this Pry::rescue{ } block" unless raised.any?

    PryRescue.enter_exception_context(raised)
  end
end
