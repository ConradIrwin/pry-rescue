require 'rubygems'
require 'interception'
require 'pry'

require File.expand_path('../pry-rescue/core_ext', __FILE__)
require File.expand_path('../pry-rescue/commands', __FILE__)

begin
  require 'pry-stack_explorer'
rescue LoadError
end

class PryRescue
  class << self

    # Start a Pry session in the context of the exception.
    # @param [Exception] exception The exception.
    # @param [Array<Binding>] bindings The call stack.
    def enter_exception_context(raised)
      exception, bindings = raised.last

      prune_call_stack!(bindings)

      if defined?(PryStackExplorer)
        pry :call_stack => bindings, :hooks => pry_hooks(exception, raised)
      else
        bindings.first.pry :hooks => pry_hooks(exception, raised)
      end
    end

    private

    # Define the :before_session hook for the Pry instance.
    # This ensures that the `_ex_` and `_raised_` sticky locals are
    # properly set.
    def pry_hooks(ex, raised)
      hooks = Pry.config.hooks.dup
      hooks.add_hook(:before_session, :save_captured_exception) do |_, _, _pry_|
        _pry_.last_exception = ex
        _pry_.backtrace = ex.backtrace
        _pry_.sticky_locals.merge!({ :_raised_ => raised })
        _pry_.exception_handler.call(_pry_.output, ex, _pry_)
      end

      hooks
    end

    # Sanitize the call stack.
    # @param [Array<Binding>] bindings The call stack.
    def prune_call_stack!(bindings)
      bindings.delete_if { |b| [Pry, Interception].include?(b.eval("self")) }
    end
  end
end
