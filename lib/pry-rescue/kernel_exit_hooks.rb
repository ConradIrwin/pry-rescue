Kernel.class_eval '@@exit_callbacks = []'

Kernel.at_exit { Kernel.run_exit_callbacks }

module Kernel
  def at_exit(&block)
    @@exit_callbacks.push block
  end

  def run_exit_callbacks
    Pry::rescue do
      @@exit_callbacks.dup.each &:call
    end
    TOPLEVEL_BINDING.pry unless PryRescue.any_exception_captured
  end
end
