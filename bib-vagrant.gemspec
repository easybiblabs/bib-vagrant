# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bib/version'

Gem::Specification.new do |spec|
  spec.name          = 'bib-vagrant'
  spec.version       = Bib::Vagrant::VERSION
  spec.authors       = %w(tillk, fh, gilleyj, seppsepp)
  spec.email         = ['till@php.net']
  spec.description   = "A rubygem to centralize configuration and setup in every project's Vagrantfile"
  spec.summary       = 'Centralize configuration and setup'
  spec.homepage      = 'https://github.com/easybiblabs/bib-vagrant'
  spec.license       = 'New BSD License'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'thor', '>= 0.18.1'
  spec.add_dependency 'colored', '>= 1.2'
  spec.add_dependency 'rest_client'
  spec.add_dependency 'json'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest', '~> 5.0.8'
  spec.add_development_dependency 'coveralls'
end
