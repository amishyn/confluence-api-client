# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'confluence/api/client/version'

Gem::Specification.new do |spec|
  spec.name          = "confluence-api-client"
  spec.version       = Confluence::Api::Client::VERSION
  spec.authors       = ["Alex Mishyn"]
  spec.email         = ["mishyn@gmail.com"]

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  end

  spec.summary       = %q{GET/POST rest client to confluence api}
  spec.description   = %q{GET/POST rest client to confluence api}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec-core"
  spec.add_development_dependency "rspec-expectations"
  spec.add_development_dependency "rspec-mocks"

  spec.add_runtime_dependency "json"
  spec.add_runtime_dependency "faraday"
  spec.add_runtime_dependency "mime-types"
end
