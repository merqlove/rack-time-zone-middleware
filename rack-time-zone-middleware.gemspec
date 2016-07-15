# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/time-zone-middleware/version'

Gem::Specification.new do |spec|
  spec.name          = 'rack-time-zone-middleware'
  spec.version       = Rack::TimeZoneMiddleware::VERSION
  spec.authors       = ['Alexander Merkulov']
  spec.email         = ['sasha@merqlove.ru']

  spec.summary       = %q{TimeZone handler middleware for Rack/Rails apps.}
  spec.description   = %q{Adding ability to detect timezone at UI side and get it within Rack/Rails via cookies with/o custom handler.}
  spec.homepage      = 'https://github.com/merqlove/rack-time-zone-middleware'

  spec.required_ruby_version = '>= 1.9.3'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.licenses      = ['MIT']

  spec.add_runtime_dependency 'activesupport', '>= 4.0.0'
  spec.add_runtime_dependency 'rack', '>= 1.2.0'

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest', '~> 5.6'
end
