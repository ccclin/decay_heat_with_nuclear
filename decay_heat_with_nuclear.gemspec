# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'decay_heat_with_nuclear/version'

Gem::Specification.new do |spec|
  spec.name          = 'decay_heat_with_nuclear'
  spec.version       = DecayHeatWithNuclear::VERSION
  spec.authors       = ['C.lin']
  spec.email         = ['demeter.yeh@gmail.com']
  spec.summary       = %q{Decay heat with nuclear.}
  spec.description   = %q{Decay heat with nuclear.}
  spec.homepage      = ''
  spec.license       = 'GPL3.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake', '~> 10.0'
end
