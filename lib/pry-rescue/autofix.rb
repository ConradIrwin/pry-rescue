class PryRescue
  class Autofix
    def self.inherited(k)
      all << k
    end

    def self.all
      @all ||= Set.new
    end

    def self.for(exception, bindings)
      all.map{ |klass| klass.new(exception, bindings) }.select(&:suggestion)
    end

    attr_reader :exception, :bindings

    def initialize(exception, bindings)
      @exception = exception
      @bindings = bindings
    end
  end
end
