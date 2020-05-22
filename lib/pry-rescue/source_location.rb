class PryRescue
  module SourceLocation
    DEPRECATION_TIME = Time.new(2021,4,1)

    WithRuby2_5 = ->(b){ [b.eval("__FILE__"), b.eval("__LINE__")] }
    WithRuby2_6 = ->(b){ b.source_location }

    define_singleton_method(
      :call,
      (RUBY_VERSION < "2.6.0") ? WithRuby2_5 : WithRuby2_6
    )
  end
end
