# -*- coding: utf-8 -*-

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
