# -*- coding: utf-8 -*-

require 'date'
require File.expand_path('../lib/tiny-abstract.rb', __FILE__)

Gem::Specification.new do |spec|
  spec.name             = 'tiny-abstract'
  spec.version          = TinyAbstract::VERSION
  spec.date             = Date.today.to_s

  spec.authors          = ['Guillaume Schlipak']
  spec.email            = ['g.de.matos@free.fr']

  spec.summary          = %q(Simple implementation of abstract classes)
  spec.description      = %q(A simple implementation of abstract classes in Ruby, through abstract method declarations)
  spec.homepage         = 'http://schlipak.github.io'
  spec.license          = 'MIT'

  spec.files            = [
    Dir.glob('lib/**/*'),
    Dir.glob('example/**/*'),
    Dir.glob('doc/**/*')
  ].flatten.delete_if { |f| not File.file? f}

  spec.require_paths    = ['lib']
end
