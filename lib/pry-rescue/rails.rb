require 'pry-rescue'
class PryRescue
  class Railtie < ::Rails::Railtie
    initializer "pry_rescue" do |app|
      app.config.middleware.use PryRescue::Rack
    end
  end
end
