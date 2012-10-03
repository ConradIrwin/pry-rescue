#!/usr/bin/env ruby

# Peeking example! Try running this example with:
#
# rescue --peek example/loop.rb
#
# Then hit <ctrl-c>, and be able to see what's going on.

def r
  some_var = 13
  loop do
    x = File.readlines('lib/pry-rescue.rb')
  end
end
r
