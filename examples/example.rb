$:.unshift File.expand_path '../../lib', __FILE__
require 'pry-capture'

Pry.capture do

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
