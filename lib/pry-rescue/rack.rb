require 'pry-rescue'
class PryRescue
  def initialize(app)
    @app = app
  end

  def call(env)
    Pry::rescue{ @app.call(env) }
  end
end
