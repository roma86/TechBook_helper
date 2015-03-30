# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'techbook_helper/version'

Gem::Specification.new do |spec|
  spec.name          = "techbook_helper"
  spec.version       = TechbookHelper::VERSION
  spec.authors       = ["Georg Romas"]
  spec.email         = ["y.romas@crestwavetech.ru"]

  spec.summary       = %q{Build start book template for TechBook from CrestWave technologies}
  spec.description   = %q{This is helper to start wright technical book stored in git with and published on TechBook developed by CrestWave technologies}
  spec.homepage      = "https://rubygems.org/gems/techbook_helper"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  #spec.bindir        = "bin"
  #spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.executables   = ['techbook']
  spec.require_paths = ["lib"]
  spec.test_files     = spec.files.grep(%r{^(test|spec|features)/})

  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "https://github.com/roma86/TechBook_helper.git"
  # end

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_runtime_dependency     "colorize"
end
