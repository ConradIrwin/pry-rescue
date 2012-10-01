#!/usr/bin/env ruby
def haywire arg
  # TODO: Figure out how to pry at the "arg" value
  if 3 == arg
    exit 1
  end
end

def dangerous
  choice = rand 55
  haywire choice
end

loop do
  dangerous
end
