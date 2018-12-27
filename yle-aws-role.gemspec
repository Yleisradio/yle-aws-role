# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yle/aws/role/version'

Gem::Specification.new do |spec|
  spec.name        = 'yle-aws-role'
  spec.version     = Yle::AWS::Role::VERSION
  spec.summary     = 'Tooling to help to assume AWS IAM roles'
  spec.description = spec.summary
  spec.homepage    = 'https://github.com/Yleisradio/yle-aws-role'
  spec.license     = 'MIT'

  spec.authors = [
    'Yleisradio',
    'Teemu Matilainen',
    'Antti Forsell',
  ]
  spec.email = [
    'devops@yle.fi',
    'teemu.matilainen@iki.fi',
    'antti@fosu.me',
  ]

  spec.files = Dir['bin/**/*'] +
               Dir['lib/**/*.rb']

  spec.bindir        = 'bin'
  spec.executables   = ['asu']
  spec.require_paths = ['lib']

  spec.add_dependency 'aws-sdk-core', '~> 3.0'
  spec.add_dependency 'slop', '~> 4.4'

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec', '~> 3.5'
end
