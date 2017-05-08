# This Exception Class behaves same as ActionView::Template::Error
# https://github.com/rails/rails/blob/master/actionview/lib/action_view/template/error.rb#L68
#
# It encapsulates an Exception and stores the latest Exception raised in its
# `cause` attribute
class TemplateError < StandardError
  attr_reader :cause

  def initialize(cause)
    @cause = $!
  end
end

