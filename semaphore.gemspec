
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "semaphore/version"

Gem::Specification.new do |spec|
  spec.name          = "semaphore"
  spec.version       = Semaphore::VERSION
  spec.authors       = ["Trae Robrock"]
  spec.email         = ["trobrock@gmail.com"]

  spec.summary       = %q{Simple semaphore with plugable backends.}
  spec.description   = %q{Simple semaphore with plugable backends.}
  spec.homepage      = "https://github.com/trobrock/semaphore"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "aws-sdk"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "fake_dynamo", "0.2.5"
  spec.add_development_dependency "rspec", ">= 2.0.0"
  spec.add_development_dependency "rspec-mocks"
  spec.add_development_dependency "rspec_junit_formatter"
end
