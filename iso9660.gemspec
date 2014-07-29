# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'iso9660/version'

Gem::Specification.new do |spec|
  spec.name          = "iso9660"
  spec.version       = Iso9660::VERSION
  spec.authors       = ["Tom Hiller"]
  spec.summary       = %q{A pure ruby ISO 9660 parsing and editing library.}
  spec.description   = %q{A pure ruby ISO 9660 parsing and editing library.}
  spec.homepage      = "https://github.com/Thrilleratplay/iso9660"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  
  spec.add_runtime_dependency "hashie"
end
