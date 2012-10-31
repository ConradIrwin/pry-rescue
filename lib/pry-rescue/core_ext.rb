# Additional methods provided by pry-rescue.
class << Pry
  # Start a pry session on any unhandled exceptions within this block.
  #
  # @example
  #   Pry::rescue do
  #     raise "foo"
  #   end
  #
  # @return [Object] The return value of the block
  def rescue(&block)
    loop do
      catch(:try_again) do
        @raised = []
        begin
          return with_rescuing(&block)
        rescue Exception => e
          rescued e unless SystemExit === e || SignalException === e
          raise e
        end
      end
    end
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
  def rescued(e=$!)
    if i = (@raised || []).index{ |(ee, _)| ee == e }
      PryRescue.enter_exception_context(@raised[0..i])
    else
      raise "Tried to inspect an exception that was not raised in a Pry::rescue{ } block"
    end

  ensure
    @raised = []
  end

  # Allow Pry::rescued(e) to work at any point in your program.
  #
  # @example
  #   Pry::enable_rescuing!
  #
  #   begin
  #     raise "foo"
  #   rescue => e
  #     Pry::rescued(e)
  #   end
  #
  def enable_rescuing!
    @raised = []
    @rescuing = true
    Interception.listen do |exception, binding|
      if defined?(PryStackExplorer)
        @raised << [exception, binding.callers]
      else
        @raised << [exception, Array(binding)]
      end
    end
  end

  private

  # Ensure that Interception is active while running this block
  #
  # @param [Proc] &block  the block
  def with_rescuing(&block)
    if @rescuing
      block.call
    else
      begin
        @rescuing = true
        Interception.listen(block) do |exception, binding|
          if defined?(PryStackExplorer)
            @raised << [exception, binding.callers]
          else
            @raised << [exception, Array(binding)]
          end
        end
      ensure
        @rescuing = false
      end
    end
  end
end
