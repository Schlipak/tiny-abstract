# -*- coding: utf-8 -*-

##
# Module which holds TinyAbstract-specific classes and variables
#
module TinyAbstract
  ##
  # Generic Error class for TibyAbstract
  #
  # * *Args*    :
  #   - *+args+ ➞ Vararg list
  # * *Returns* :
  #   - +self+
  #
  class Error < StandardError
  end

  ##
  # Error raised when instantiating an abstract class
  #
  class InstantiationError < Error
    ##
    # Main error message
    #
    attr_reader :message

    ##
    # List of unimplemented abstract methods
    # that triggered the error
    #
    attr_reader :abstract_methods

    ##
    # initializes the error
    #
    # * *Args*    :
    #   - +message+ ➞ The error message
    #   - +abstract_methods+ ➞ The list of abstract methods
    # * *Returns* :
    #   - +self+
    #
    def initialize(message, abstract_methods)
      @message = message
      @abstract_methods = abstract_methods
    end

    ##
    # Gives a string representation of the error
    #
    # * *Returns*   :
    #   - +String+ ➞ The string representation of the error
    #
    def to_s
      plur = @abstract_methods.length > 1 ? 's' : ''
      methods = ":#{@abstract_methods.join(', :')}"
      subMsg = "(Unimplemented method#{plur} #{methods})"
      "#{@message} #{subMsg}"
    end
  end
end
