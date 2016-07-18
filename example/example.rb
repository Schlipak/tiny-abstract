#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'tiny-abstract'

##
# Example module
#
module Example
  ##
  # Abstract class A
  #
  # Here we define abstract methods +:foo+, +:bar+, and +:baz+.
  #
  # +:foo+ is implemented, thus it is a registered abstract
  # but implemented method.
  #
  # Since A still has unimplemented registered methods, it
  # is not instantiable.
  #
  class A
    abstract :foo, :bar, :baz

    def initialize(value)
      @value = value
    end

    def foo
      @value.times do |i|
        puts "#{i} -> Foo!"
      end
    end
  end

  ##
  # Abstract class B inherits A
  #
  # The B class inherits the abstract methods of A.
  # Since +:foo+ was already implemented, it is not inherited
  # as an abstract method by B.
  #
  # We also define a new abstract method +:qux+, which is added
  # to the inherited abstract method list.
  #
  # This means B now holds the following abstract unimplemented
  # methods:<br>
  # +:bar+, +:baz+, +:qux+
  #
  # We then implement +:bar+, making it a registered but
  # implemented abstract method.
  # It is then ignored from the abstract checks.
  #
  # The B class still contains +:baz+ and +:qux+ as registered
  # unimplemented methods.
  # Thus it is abstract and not instantiable.
  #
  class B < A
    abstract :qux

    def bar
      @value.times do |i|
        puts "#{i} -> Bar!"
      end
    end
  end

  ##
  # Class C inherits B
  #
  # This class inherits the abstract methods +:baz+ and +:qux+
  # from B.
  #
  # Both are implemented, and no others are defined, which
  # means the C class is concrete, and can be instantiated.
  #
  class C < B
    def baz
      @value.times do |i|
        puts "#{i} -> Baz!"
      end
    end

    def qux
      @value.times do |i|
        puts "#{i} -> Qux!"
      end
    end
  end
end

if __FILE__ == $0
  # We cannot instantiate the class A since it is abstract
  begin
    a = Example::A.new 3
    a.foo
  rescue TinyAbstract::InstantiationError => e
    $stderr.puts e.to_s
  end

  # Same thing for the class B
  begin
    b = Example::B.new 3
    b.foo
    b.bar
  rescue TinyAbstract::InstantiationError => e
    $stderr.puts e.to_s
  end

  # But class C works!
  c = Example::C.new 3
  c.foo
  c.bar
  c.baz
  c.qux
end
