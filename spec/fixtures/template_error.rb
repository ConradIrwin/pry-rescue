class TemplateError < StandardError
  attr_reader :cause

  def initialize(cause)
    @cause = $!
  end
end

