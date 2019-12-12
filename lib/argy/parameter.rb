require "pathname"
require "argy/parameter"

module Argy
  # @abstract Subclasses must implement {#label}
  class Parameter
    # The name of the parameter
    # @return [String]
    attr_reader :name

    # The type of the parameter
    # @return [String]
    attr_reader :type

    # The default value for the parameter
    # @return [Object]
    attr_reader :default

    # The description for the parameter
    # @return [String]
    attr_reader :desc

    # Create a new Parameter
    # @param name [Symbol] name of the parameter
    # @param desc [String,nil] description for the parameter
    # @param type [Symbol,#call] type of parameter
    # @param default [Object] default value for the parameter
    # @param required [TrueClass,FalseClass] whether or not the field is required
    def initialize(name, desc: nil, type: :string, default: nil, required: false)
      @name = name
      @type = type
      @desc = desc
      @default = default
      @required = required
    end

    # The display label for the paramter
    # @abstract
    # @return [String]
    def label
      raise NotImplementedError, __method__
    end

    # Check if the parameter is required
    # @return [TrueClass,FalseClass]
    def required?
      @required
    end

    # Validates a value.
    # @return [Object] the value
    # @raise [ValidationError] if the valid is invalid
    def validate(value)
      if required? && value.nil?
        raise ValidationError, "`#{label}` is a required parameter"
      end

      value
    end

    # Coerces a value to the correct type.
    # @param value [Object] the value to coerce
    # @raise [CoersionError] if the value cannot be coerced
    def coerce(value)
      case type
      when :string, :boolean
        value
      when :integer
        Integer(value)
      when :float
        Float(value)
      when :array
        value.split(",")
      when :pathname
        Pathname.new(value).expand_path(Dir.pwd)
      else
        raise "Invalid type: #{type.inspect}" unless type.respond_to?(:call)
        type.call(value)
      end
    rescue ArgumentError
      raise CoersionError, "`#{label}` received an invalid value"
    end
  end
end
