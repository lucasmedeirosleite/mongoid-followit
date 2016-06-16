# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mongoid_followit/version'

Gem::Specification.new do |spec|
  spec.name          = 'mongoid_followit'
  spec.version       = Mongoid::Followit::VERSION
  spec.authors       = ['Lucas Medeiros']
  spec.email         = ['lucastoc@gmail.com']

  spec.summary       = %q{ Follow/Unfollow feature for MongoDB documents. }
  spec.description   = %q{ Follow/Unfollow feature for MongoDB documents. }
  spec.homepage      = 'https://github.com/lucasmedeirosleite'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|metrics)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '>= 4.0'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'mongoid', '>= 4.0.0'

  spec.add_development_dependency 'rubycritic', '~> 2.9'
  spec.add_development_dependency 'pry-byebug', '~> 3.4.0'
end
