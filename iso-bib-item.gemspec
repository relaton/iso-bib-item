# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'iso_bib_item/version'

Gem::Specification.new do |spec|
  spec.name          = 'iso-bib-item'
  spec.version       = IsoBibItem::VERSION
  spec.authors       = ['Ribose Inc.']
  spec.email         = ['open.source@ribose.com']

  spec.summary       = %(IsoBibItem: Ruby ISOXMLDOC impementation.)
  spec.description   = %(IsoBibItem: Ruby ISOXMLDOC impementation.)
  spec.homepage      = 'https://github.com/metanorma/iso-bib-item'
  spec.license       = 'BSD-2-Clause'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.add_development_dependency 'bundler', '~> 2.0.1'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency "equivalent-xml", "~> 0.6"

  spec.add_dependency 'isoics', '~> 0.1.6'
  spec.add_dependency 'nokogiri', "~> 1.8.4"
  spec.add_dependency 'ruby_deep_clone', "~> 0.8.0"
end
