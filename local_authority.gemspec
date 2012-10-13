# -*- encoding: utf-8 -*-
require File.expand_path('../lib/local_authority/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Craig R Webster"]
  gem.email         = ["craig@barkingiguana.com"]
  gem.description   = %q{Local authority information and links to further datasets}
  gem.summary       = %q{Local authority information and links to further datasets}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "local_authority"
  gem.require_paths = ["lib"]
  gem.version       = LocalAuthority::VERSION

  gem.add_development_dependency 'nokogiri'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'my_society-map_it', '~> 0.0.5'
end
