require "argy/parameter"

module Argy
  class Parameter
    attr_reader :name, :type, :aliases, :desc, :default

    def initialize(name, aliases: [], desc: nil, type: :string, default: nil, required: false)
      @name = name
      @type = type
      @aliases = aliases
      @desc = desc
      @default = default
      @required = required
    end

    def label
      raise NotImplementedError, __method__
    end

    def required?
      @required
    end

    def validate(value)
      if required? && value.nil?
        raise ValidationError, "`#{label}` is a required parameter"
      end
    end

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
