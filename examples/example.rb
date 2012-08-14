$:.unshift File.expand_path '../../lib', __FILE__
require 'pry-rescue'

Pry.rescue do

  def a
    begin
      begin
        raise "foo"

      rescue => e
        raise "bar"
      end

    rescue => e
      1 / 0

    end
  end
  a
end
