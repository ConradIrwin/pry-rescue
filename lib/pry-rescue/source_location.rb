
if binding.respond_to?(:source_location)
  raise 'source_location exists by default in Ruby 2.6 and greater, no need to required it manually'
else
  class PryRescue
    module SourceLocation
      DEPRECATION_TIME = Time.new(2021,4,1)

      WithRuby2_5 = ->(b){ [b.eval("__FILE__"), b.eval("__LINE__")] }
    end
  end

  Binding.define_method(:source_location, &PryRescue::SourceLocation::WithRuby2_5)
end
