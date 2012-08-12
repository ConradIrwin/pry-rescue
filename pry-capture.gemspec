Gem::Specification.new do |s|
  s.name          = 'pry-capture'
  s.version       = '0.1'
  s.summary       = 'Open a pry session on any unhandled exceptions'
  s.description   = 'Allows you to wrap code in Pry::capture{ } to open a pry session at any unhandled exceptions'
  s.homepage      = 'https://github.com/ConradIrwin/pry-capture'
  s.email         = ['conrad.irwin@gmail.com', 'jrmair@gmail.com']
  s.authors       = ['Conrad Irwin', 'banisterfiend']
  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]

  s.add_dependency 'interception'
end
