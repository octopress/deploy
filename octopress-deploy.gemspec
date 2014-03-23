# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'octopress-deploy/version'

Gem::Specification.new do |spec|
  spec.name          = "octopress-deploy"
  spec.version       = Octopress::Deploy::VERSION
  spec.authors       = ["Brandon Mathis"]
  spec.email         = ["brandon@imathis.com"]
  spec.description   = %q{Deploy Octopress and Jekyll sites easily}
  spec.summary       = %q{Deploy Octopress and Jekyll sites easily}
  spec.homepage      = "https://github.com/octopress/deploy"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "octopress", "~> 3.0.0.rc.1"
  spec.add_runtime_dependency "colorator"

  spec.add_development_dependency "octopress-ink"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
