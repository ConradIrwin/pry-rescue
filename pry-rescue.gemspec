Gem::Specification.new do |s|
  s.name          = 'pry-rescue'
  s.version       = '1.4.5'
  s.summary       = 'Open a pry session on any unhandled exceptions'
  s.description   = 'Allows you to wrap code in Pry::rescue{ } to open a pry session at any unhandled exceptions'
  s.homepage      = 'https://github.com/ConradIrwin/pry-rescue'
  s.email         = ['conrad.irwin@gmail.com', 'jrmair@gmail.com', 'chris@ill-logic.com']
  s.authors       = ['Conrad Irwin', 'banisterfiend', 'epitron']
  s.files         = `git ls-files`.split("\n")
  s.license       = 'MIT'
  s.require_paths = ['lib']
  s.executables   = s.files.grep(%r{^bin/}).map{|f| File.basename f}

  s.add_dependency 'pry'
  s.add_dependency 'interception', '>= 0.5'

  s.add_development_dependency 'pry-stack_explorer' # upgrade to regular dep?

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'redcarpet'
  s.add_development_dependency 'capybara'

  # SPECIAL DEVELOPMENT GEM FOR OLD RUBY
  # DONT USE THIS TRICK FOR RUNTIME GEM
  if Gem::Version.create(RUBY_VERSION) < Gem::Version.create("2.2.2")
    s.add_development_dependency 'yard', '< 0.9.6'
    s.add_development_dependency 'rack', ['~> 1.6', '< 1.7']
  else
    s.add_development_dependency 'yard'
  end
  if Gem::Version.create(RUBY_VERSION) < Gem::Version.create("2.1")
    # capybara > nokogiri
    s.add_development_dependency 'nokogiri', ['~> 1.6', '< 1.7.0']
  end
  if Gem::Version.create(RUBY_VERSION) < Gem::Version.create("2.0")
    # capybara > addressable > public_suffix
    s.add_development_dependency 'public_suffix', ['~> 1.4', '< 1.5']
    # capybara > mime-types
    s.add_development_dependency 'mime-types', ['~> 2.6', '< 2.99']
  end
end
