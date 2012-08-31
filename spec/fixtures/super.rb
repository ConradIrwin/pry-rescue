class A
  def a
    loop do
      raise "fixtures/super"
    end
  end
end

class B < A
  def a
    loop do
      super
    end
  end
end

B.new.a
