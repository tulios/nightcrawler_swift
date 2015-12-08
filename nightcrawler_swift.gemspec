# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nightcrawler_swift/version'

Gem::Specification.new do |spec|
  spec.name          = "nightcrawler_swift"
  spec.version       = NightcrawlerSwift::VERSION
  spec.authors       = ["tulios", "robertosoares"]
  spec.email         = ["ornelas.tulio@gmail.com", "roberto.tech@gmail.com"]
  spec.summary       = %q{Like the X-Men nightcrawler this gem teleports your assets to a OpenStack Swift bucket/container}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/tulios/nightcrawler_swift"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rest-client"
  spec.add_dependency "multi_mime",      ">= 1.0.1"
  spec.add_dependency "concurrent-ruby", "~> 0.8.0"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "codeclimate-test-reporter"
  spec.add_development_dependency "timecop"

  if RUBY_VERSION =~ /1\.9/
    spec.add_development_dependency "debugger"
  else
    spec.add_development_dependency "byebug"
  end
end
