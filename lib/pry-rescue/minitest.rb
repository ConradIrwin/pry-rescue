require 'pry-rescue'
# TODO: it should be possible to do all this by simply wrapping
# MiniTest::Unit::TestCase in recent versions of minitest.
# Unfortunately the version of minitest bundled with ruby seems to
# take precedence over the new gem, so we can't do this and still
# support ruby-1.9.3
class MiniTest::Unit::TestCase
  alias_method :run_without_rescue, :run

  def run(runner)
    Pry::rescue do
      run_without_rescue(runner)
    end
  end
end

class << MiniTest::Unit.runner
  alias_method :puke_without_rescue, :puke

  def puke(suite, test, e)
    Pry::rescued(e)
    puke_without_rescue(suite, test, e)
  end
end
