# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
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

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = 'bin'
  spec.executables   = ['asu']
  spec.require_paths = ['lib']

  spec.add_dependency 'aws-sdk', '~> 2.6'
  spec.add_dependency 'slop', '~> 4.4'

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 11.0'
  spec.add_development_dependency 'rspec', '~> 3.5'
end
