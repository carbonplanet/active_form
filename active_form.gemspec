# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)


Gem::Specification.new do |spec|
  spec.name          = "active_form"
  spec.version       = '0.0.8.1'
  spec.authors       = ["Carbon Planet Limited"]
  spec.email         = ["support@carbonplanet.com"]
  spec.summary       = "Legacy Active Form gem"
  spec.description   = "Legacy copy of Fabien Franzen's Active Form gem"
  spec.homepage      = "https://github.com/ferrisoxide/active_form"
  spec.license       = "Private"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'actionpack', '>= 2.3.8'

  spec.add_development_dependency "bundler", '~> 1.9'
  spec.add_development_dependency "rake",    '~> 10.4'
  spec.add_development_dependency 'rspec',   '~> 3'
  spec.add_development_dependency "pry",     '~> 0.10'

end
