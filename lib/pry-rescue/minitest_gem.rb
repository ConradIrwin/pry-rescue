require 'pry-rescue'

class Minitest::Test
  alias_method :run_without_rescue, :run

  # Minitest 5 handles all unknown exceptions, so to get them out of
  # minitest, we need to add Exception to its passthrough types
  def run
    Minitest::Test::PASSTHROUGH_EXCEPTIONS << Exception
    Pry::rescue do
      run_without_rescue
    end
  end
end
