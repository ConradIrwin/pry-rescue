require 'rubygems'
require 'interception'
require 'pry'

require File.expand_path('../pry-rescue/core_ext', __FILE__)
require File.expand_path('../pry-rescue/commands', __FILE__)
require File.expand_path('../pry-rescue/rack', __FILE__)

begin
  require 'pry-stack_explorer'
rescue LoadError
end

# PryRescue provides the ability to open a Pry shell whenever an unhandled exception is
# raised in your code.
#
# The main API is exposed via the Pry object, but here are a load of helpers that I didn't
# want to pollute the Pry namespace with.
#
# @see {Pry::rescue}
class PryRescue
  class << self

    # Start a Pry session in the context of the exception.
    # @param [Array<Exception, Array<Binding>>] raised  The exceptions raised
    def enter_exception_context(raised)

      raised = raised.map do |e, bs|
        [e, without_bindings_below_raise(bs)]
      end
      raised = without_gem_reraises(raised)

      raised.pop if phantom_load_raise?(*raised.last)
      exception, bindings = raised.last
      bindings = without_duplicates(bindings)

      if defined?(PryStackExplorer)
        pry :call_stack => bindings,
            :hooks => pry_hooks(exception, raised),
            :initial_frame => initial_frame(bindings)
      else
        Pry.start bindings.first, :hooks => pry_hooks(exception, raised)
      end
    end

    # Load a script wrapped in Pry::rescue{ }
    # @param [String] script  The name of the script
    def load(script)
      Pry::rescue{ Kernel.load script }
    end

    private

    # Did this raise happen within pry-rescue?
    #
    # This is designed to remove the extra raise that is caused by PryRescue.load.
    # TODO: we should figure out why it happens...
    #
    # @param [Exception] e  The raised exception
    # @param [Array<Binding>] bindings  The call stack
    def phantom_load_raise?(e, bindings)
      bindings.any? && bindings.first.eval("__FILE__") == __FILE__
    end

    # When using pry-stack-explorer we want to start the rescue session outside of gems
    # and the standard library, as that is most helpful for users.
    #
    # @param [Array<Bindings>] bindings  All bindings
    # @return [Fixnum]  The offset of the first binding of user code
    def initial_frame(bindings)
      bindings.each_with_index do |binding, i|
        return i if user_path?(binding.eval("__FILE__"))
      end

      0
    end

    # Is this path likely to be code the user is working with right now?
    #
    # @param [String] file  the absolute path
    # @return [Boolean]
    def user_path?(file)
      !file.start_with?(RbConfig::CONFIG['libdir']) &&
      !Gem::Specification.any?{ |gem| file.start_with?(gem.full_gem_path) }
    end

    # Remove bindings that are part of Interception/Pry.rescue's internal
    # event handling that happens as part of the exception hooking process.
    #
    # @param [Array<Binding>] bindings  The call stack.
    def without_bindings_below_raise(bindings)
      return bindings if bindings.size <= 1
      bindings.drop_while do |b|
        b.eval("__FILE__") == File.expand_path("../pry-rescue/core_ext.rb", __FILE__)
      end.drop_while do |b|
        b.eval("self") == Interception
      end
    end

    # Remove multiple bindings for the same function.
    #
    # @param [Array<Bindings>] bindings  The call stack
    # @return [Array<Bindings>]
    def without_duplicates(bindings)
      bindings.zip([nil] + bindings).reject do |b, c|
        # The eval('__method__') is there as a shortcut as loading a method
        # from a binding is very slow.
        c && (b.eval("__method__") == c.eval("__method__")) &&
                    Pry::Method.from_binding(b) == Pry::Method.from_binding(c)
      end.map(&:first)
    end

    # Remove any re-raises of the exact exception object that happened from within
    # a gem, and show you only the raise that happened in your code.
    #
    # @param [Array<Exception, Array<Binding>>] raised  The exceptions raised
    def without_gem_reraises(raised)
      seen = {}
      raised.select do |(e, bindings)|
        if seen[e] && !user_path?(bindings.first.eval("__FILE__"))
          false
        elsif user_path?(bindings.first.eval("__FILE__"))
          seen[e] = true
        else
          true
        end
      end
    end

    # Define the :before_session hook for the Pry instance.
    # This ensures that the `_ex_` and `_raised_` sticky locals are
    # properly set.
    #
    # @param [Exception] ex  The exception we're currently looking at
    # @param [Array<Exception, Array<Binding>>] raised  The exceptions raised
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
  end
end
