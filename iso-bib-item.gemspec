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
  spec.homepage      = 'https://github.com/riboseinc/gdbib'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov'

  spec.add_dependency 'isoics', '~> 0.1.6'
  spec.add_dependency 'nokogiri'
end
