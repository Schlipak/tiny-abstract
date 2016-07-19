# -*- coding: utf-8 -*-

Dir[File.dirname(__FILE__) + '/**/*.rb'].each { |f| require f }

##
# Extension of the Class class to provide
# a basic abstract methods implementation
#
class Class
  ##
  # The previous ::new method. Do not call.
  #
  alias_method :new_class, :new

  ##
  # Allocates a new Class and initializes the
  # inherited abstract methods
  #
  # * *Args*    :
  #   - *+args+ ➞ Vararg list
  #   - &+block+ ➞ Block given
  # * *Returns* :
  #   - Class instance
  #
  def new(*args, &block)
    obj = new_class(*args, &block)
    obj.class.send :inherit_abstract
    obj
  end

  @@_whitelist ||= []

  CLASS_BLACKLIST ||= [
    Array, Hash,
    String, StringIO, Symbol,
    Numeric,
    Exception
  ].freeze

  MODULE_BLACKLIST ||= [
    'RubyToken', 'Psych', 'Timeout',
    'Brimstone', 'RubyGem', 'Gem',
    'Array', 'Digest', 'Zlib'
  ].freeze

  ABSOLUTE_BLACKLIST ||= [
    BasicObject, Object, Kernel, ObjectSpace
  ].freeze

  ##
  # Registers the given symbols as abstract methods
  #
  # * *Args*    :
  #   - *+syms+ ➞ Vararg list of symbols
  # * *Returns* :
  #   - Total number of abstract methods as +Fixnum+
  # * *Raises*  :
  #   - +TinyAbstract::Error+ ➞ If abstract is forbidden for this class
  #
  def abstract(*syms)
    unless self.send :check_blacklist
      raise TinyAbstract::Error.new, "Cannot make blacklisted #{self} class abstract"
    end
    @@_whitelist << self
    update = (syms.first != false)
    @_abstract_methods ||= Array.new
    return unless syms.respond_to? :each
    syms.each do |sym|
      next unless sym.is_a? Symbol
      @_abstract_methods << sym
    end
    @_abstract_methods = @_abstract_methods.flatten.uniq.sort
    self.send :update_descendants if update
    @_abstract_methods.length
  end

  ##
  # Lists the unimplemented abstract methods
  #
  # * *Returns* :
  #   - +Array+ of +Symbol+ ➞ The list of unimplemented abstract methods
  #
  def abstract_methods
    methods = Array.new
    self.send :inherit_abstract
    return methods unless @_abstract_methods.respond_to? :each
    @_abstract_methods.each do |sym|
      methods << sym unless self.method_defined? sym
    end
    methods
  end

  ##
  # Checks if the class is abstract.
  #
  # * *Returns* :
  #   - +TrueClass+ | +FalseClass+ ➞ Whether or not the class is abstract
  #
  def abstract?
    return false unless @_abstract_methods.respond_to? :each
    self.send :inherit_abstract
    @_abstract_methods.each do |sym|
      return true unless self.method_defined? sym
    end
    false
  end

  private
  ##
  # Checks if the class is allowed to hold abstract methods.
  # This rejects blacklisted classes such as some
  # base Ruby classes.
  #
  # * *Args*    :
  #   - +strict+ ➞ +TrueClass+ | +FalseClass+ Perform a strict check (default +false+)
  # * *Returns* :
  #   - +TrueClass+ | +FalseClass+ ➞ Whether or not the class is allowed to hold abstract methods
  #
  def check_blacklist(strict = false)
    MODULE_BLACKLIST.each do |modul|
      break if self.name.nil?
      return false if self.name.gsub(/::.*/, '') == modul.to_s
    end
    CLASS_BLACKLIST.each do |klass|
      return false if self.ancestors.include? klass
    end
    return false if ABSOLUTE_BLACKLIST.include?(self)
    return false if ABSOLUTE_BLACKLIST.include?(self.superclass) and strict
    true
  end

  ##
  # Checks if the class is allowed to perform abstraction checks.
  # This includes any class that has registered abstract methods,
  # and all of its descendants.
  #
  # * *Returns* :
  #   - +TrueClass+ | +FalseClass+ ➞ Whether or not the class is allowed to perform abstraction checks
  #
  def check_whitelist
    not (@@_whitelist & self.ancestors).empty?
  end

  ##
  # Inherits the superclass' abstract methods
  #
  def inherit_abstract
    return unless self.send(:check_whitelist)
    self.abstract(
      *[false, self.superclass.abstract_methods].flatten
    )
  end

  ##
  # Update the class' descendants' abstract methods
  #
  def update_descendants
    self.descendants.each do |klass|
      klass.send :inherit_abstract
    end
  end
end

##
# Extension of the Object class
#
# Adds an abstract check at instantiation, and a helper
# method to get an object's descendants
#
class Object
  class << self
    ##
    # The previous ::new method. Do not call.
    #
    alias_method :new_object, :new
    ##
    # Allocates a new Object, checks if it is instantiable
    # depending on its abstract methods, then initializes it
    #
    # * *Args*    :
    #   - *+args+ ➞ Vararg list
    #   - &+block+ ➞ Block given
    # * *Returns* :
    #   - +self.class+ The Object instance
    # * *Raises*  :
    #   - +TinyAbstract::InstantiationError+ ➞ If +self.class+ is abstract
    #
    def new(*args, &block)
      obj = new_object(*args, &block)
      if obj.class.abstract?
        message = "Cannot instantiate abstract class #{obj.class}"
        raise TinyAbstract::InstantiationError.new(message, obj.class.abstract_methods)
      end
      obj
    end
  end

  ##
  # Lists all the descendants of this class
  #
  # * *Returns* :
  #   - +Array+ of +Symbol+ ➞ The list of descendant classes
  #
  def self.descendants
    ObjectSpace.each_object(Class).select {|klass| klass < self}
  end
end
