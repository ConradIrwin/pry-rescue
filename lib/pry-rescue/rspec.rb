require 'pry-rescue'
require 'pry-stack_explorer'
require 'rspec' unless defined?(RSpec)

class PryRescue
  class RSpec

    # Run an Rspec example within Pry::rescue{ }.
    #
    # Takes care to ensure that `try-again` will work.
    #
    # `example` is a RSpec::Core::Example::Procsy
    def self.run(example)
      Pry::rescue do
        begin
          before

          example.example.instance_variable_set(:@exception, nil)
          example.example_group_instance.instance_variable_set(:@__init_memoized, true)

          example.run

          # Rescued will be called in :after hook, which is ran before the second
          # :around leg

        ensure
          after_outside
        end
      end
    end

    def self.before
      monkeypatch_capybara if defined?(Capybara)
    end

    def self.after(example)
      e = example.exception
      Pry::rescued(e) if e
    end

    def self.after_outside
      after_filters.each(&:call)
    end

    # Shunt Capybara's after filter from before Pry::rescued to after.
    #
    # The after filter navigates to 'about:blank', but people debugging
    # tests probably want to see the page that failed.
    def self.monkeypatch_capybara
      unless Capybara.respond_to?(:reset_sessions_after_rescue!)
        class << Capybara
          alias_method :reset_sessions_after_rescue!, :reset_sessions!
          def reset_sessions!
            return if Capybara.raise_server_errors

            session_pool.reverse_each do |_mode, session|
              session.server.reset_error!
            end
          end
        end

        after_filters << Capybara.method(:reset_sessions_after_rescue!)
      end
    end

    def self.after_filters
      @after_filters ||= []
    end
  end
end

RSpec.configure do |c|
  c.around(:each) do |example|
    PryRescue::RSpec.run example
  end

  c.after(:each) do |example|
    PryRescue::RSpec.after(example)
  end
end
