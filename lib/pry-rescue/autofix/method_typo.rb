require 'levenshtein'

class PryRescue
  class MethodTypo < Autofix

    def suggestion
      return unless exception.class == NoMethodError && missing_name && receiver_string && replacement
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

    def receiver
      bindings.first.eval(receiver_string)
    end

    def receiver_string
      $` if buggy_line =~ /\.#{Regexp.escape(missing_name)}/
    end

    def buggy_line
      # TODO, handle (pry) properly
      File.read(bindings.first.eval("__FILE__")).lines.to_a[bindings.first.eval("__LINE__") - 1]
    end

    def edit_method(&block)
      MethodEditor.new(bindings.first, &block).perform_patch
    end

    def missing_name
      exception.message[/\Aundefined method `([^']*)' for/, 1]
    end

    def replacement
      @replacement ||=(
        if scored_suggestions.any? && scored_suggestions.first.first < 2
          scored_suggestions.first.last
        end
      )
    end

    def scored_suggestions
      receiver_methods.map do |lvar|
        [Levenshtein.distance(missing_name, lvar), lvar]
      end.sort
    end

    def receiver_methods
      r = begin
            receiver or return []
          rescue Pry::RescuableException
            return []
          end
      Object.instance_method(:methods).bind(r).call(true).map(&:to_s) +
      Object.instance_method(:private_methods).bind(r).call(true).map(&:to_s)
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
