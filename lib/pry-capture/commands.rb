Pry::Commands.create_command "cd-cause", "Move to the previously raised exception"  do

  banner <<-BANNER
    Usage: cd-cause

    Starts a new pry session at the previously raised exception.

    This is useful if you've caught one exception, and raised another,
    if you need to find out why the original was raised.

    @example
      5.    def foo
      6.      raise "one"
      7.    rescue
      8. =>    raise "two"
      9.    end

      pry> cd-cause

      5.    def foo
      6. =>    raise "one"
      7.    rescue
      8.       raise "two"
      9.    end

    Once you have finished with the internal exception type <ctrl+d> or cd .. to
    return to where you were.

    If you have many layers of exceptions that are rescued and then re-raised, you
    can repeat cd-cause as many times as you need.
  BANNER

  def process
    raised = target.eval("_raised_ rescue nil")
    raise Pry::CommandError, "cd-cause only works in a pry session created by Pry::capture{}" unless raised
    raised.pop

    if raised.any?
      exception, bindings = raised.last
      Pry.enter_exception_context(exception, bindings, raised)
    else
      raise Pry::CommandError, "No previous exception detected"
    end
  end
end
