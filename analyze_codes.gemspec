# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'analyze_codes/version'

Gem::Specification.new do |gem|
  gem.name          = "analyze_codes"
  gem.version       = AnalyzeCodes::VERSION
  gem.authors       = ["Marc Hadley"]
  gem.email         = ["mhadley@mitre.org"]
  gem.description   = %q{A library for analyzing value set and measure population coverage of the codes contained in a patient population.}
  gem.summary       = %q{A library for analyzing value set and measure population coverage of the codes contained in a patient population.}
  gem.homepage      = ""
  
  gem.add_dependency 'health-data-standards', '~>3.0.6'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
