require 'levenshtein'

class PryRescue
  class LocalTypo < Autofix

    def suggestion
      return unless exception.class == NameError && missing_name && replacement
      return "replace #{missing_name.inspect} by #{replacement.inspect}"
    end

    def fix!
      edit_method do |old_text|
        old_text.gsub(/\b#{Regexp.escape(missing_name)}\b/, replacement)
      end

      code = Pry::Code.from_method(Pry::Method.from_binding(bindings.first))
      puts "\n#{code.with_line_numbers(true).to_s}\n"
    end

    private

    def edit_method(&block)
      MethodEditor.new(bindings.first, &block).perform_patch
    end

    def missing_name
      @missing_name ||=(
        $1 if exception.message =~ /undefined local variable or method `(.*)'/
      )
    end

    def replacement
      @replacement ||=(
        if scored_suggestions.any? && scored_suggestions.first.first < 2
          scored_suggestions.first.last
        end
      )
    end

    def scored_suggestions
      local_variables.map do |lvar|
        [Levenshtein.distance(missing_name, lvar), lvar]
      end.sort
    end

    def local_variables
      b = bindings.first
      (b.eval("::Kernel.local_variables") +
       b.eval("methods(true)") +
       b.eval("private_methods(true)")).map(&:to_s)
    end
  end
end

class MethodEditor < Pry::Command::Edit::MethodPatcher
  def initialize(binding, &block)
    @code_object = Pry::Method.from_binding(binding)
    @_pry_ = Pry.new
    @block = block
  end

  def patched_code
    @patched_code ||= wrap(@block.call(adjusted_lines.join))
  end
end
