Gem::Specification.new do |s|
  s.name          = 'pry-rescue'
  s.version       = '0.7'
  s.summary       = 'Open a pry session on any unhandled exceptions'
  s.description   = 'Allows you to wrap code in Pry::rescue{ } to open a pry session at any unhandled exceptions'
  s.homepage      = 'https://github.com/ConradIrwin/pry-rescue'
  s.email         = ['conrad.irwin@gmail.com', 'jrmair@gmail.com', 'chris@ill-logic.com']
  s.authors       = ['Conrad Irwin', 'banisterfiend', 'epitron']
  s.files         = `git ls-files`.split("\n")
  s.require_paths = ['lib']
  s.executables   = ['rescue']

  s.add_dependency 'pry'
  s.add_dependency 'interception'
end
