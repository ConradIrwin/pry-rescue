require 'pry'
RSpec.configure do |c|
  c.around(:each) do |example|
    Pry::rescue do
      example.binding.eval('@exception = nil')
      example.run
      if e = example.binding.eval('@exception')
        Pry::rescued(e)
      end
    end
  end
end
