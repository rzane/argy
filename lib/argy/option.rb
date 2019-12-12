require "argy/parameter"

module Argy
  # An option to be parsed from the command line
  class Option < Parameter
    # A list of alternative flags
    # @return [Array<String>]
    attr_reader :aliases

    # Create a new Option
    # @param name [Symbol] name of the parameter
    # @param aliases [Array<String>] a list of alternative flags
    # @param desc [String,nil] description for the parameter
    # @param type [Symbol,#call] type of parameter
    # @param default [Object] default value for the parameter
    # @param required [TrueClass,FalseClass] whether or not the field is required
    def initialize(*args, aliases: [], **opts)
      super(*args, **opts)
      @aliases = aliases
    end

    # The display label for the argument
    # @return [String]
    def label
      case type
      when :boolean
        "--[no-]#{name.to_s.tr("_", "-")}"
      else
        "--#{name.to_s.tr("_", "-")}"
      end
    end

    # @private
    def to_option_parser
      options = []
      options << aliases.join(" ") unless aliases.empty?

      case type
      when :boolean
        options << label
      else
        options << "#{label}=#{name.to_s.upcase}"
        options << "#{label} #{name.to_s.upcase}"
      end

      options << desc if desc
      options
    end
  end
end
