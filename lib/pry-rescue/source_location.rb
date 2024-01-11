if binding.respond_to?(:source_location)
  raise 'source_location exists by default in Ruby 2.6 and greater, no need to required it manually'
else
  class PryRescue
    module SourceLocation
      def self.call(b)
        [b.eval("__FILE__"), b.eval("__LINE__")]
      end
    end
  end

  Binding.define_method :source_location do
    PryRescue::SourceLocation.call(self)
  end
end
