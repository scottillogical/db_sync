# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'db_sync/version'

Gem::Specification.new do |spec|
  spec.name          = "db_sync"
  spec.version       = DbSync::VERSION
  spec.authors       = ["Scott Schulthess"]
  spec.email         = ["scottschulthess@gmail.com"]
  spec.description   = %q{Rails gem for syncing database tables}
  spec.summary       = %q{This Rails gem provides rake tasks for exporting certain tables from say production and loading them into development}
  spec.homepage      = "http://github.com/scottschulthess/db_sync"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
