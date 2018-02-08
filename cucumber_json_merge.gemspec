# frozen_string_literal: true
# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cucumber_json_merge/version'

Gem::Specification.new do |spec|
  spec.name          = 'cucumber_json_merge'
  spec.version       = CucumberJsonMerge::VERSION
  spec.authors       = ['Voke Ransom Anighoro']
  spec.email         = ['voke.anighoro@gmail.com']

  spec.summary       = 'Tool to merge cucumber generated JSON files'
  spec.description   = 'Tool to merge cucumber generated JSON files'
  spec.homepage      = 'https://github.com/ransom4real/cucumber_json_merge'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.executables = `git ls-files -- bin/*`.split("\n").map { |f|
    File.basename(f)
  }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_runtime_dependency 'json', '~> 2.1'
  spec.add_runtime_dependency 'deep_merge', '~> 1.2'
end
