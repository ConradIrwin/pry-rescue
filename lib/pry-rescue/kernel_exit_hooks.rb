class << PryRescue
  def exit_callbacks
    @exit_callbacks ||= []
  end

  def run_exit_callbacks
    Pry::rescue do
      exit_callbacks.dup.each(&:call)
    end
    TOPLEVEL_BINDING.pry unless any_exception_captured
  end
end

Kernel.at_exit { PryRescue.run_exit_callbacks }

module Kernel
  def at_exit(&block)
    PryRescue.exit_callbacks.push block
  end
end
