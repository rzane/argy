require "optparse"
require "argy/help"
require "argy/option"
require "argy/argument"
require "argy/options"

module Argy
  # Parses command line arguments.
  class Parser
    # The examples that were declared
    # @return [Array<String>]
    attr_reader :examples

    # The arguments that were declared
    # @return [Array<Argument>]
    attr_reader :arguments

    # The options that were declared
    # @return [Array<Option>]
    attr_reader :options

    # The flags that were declared
    # @return [Array<Array(Array<String>, Proc)>]
    attr_reader :flags

    def initialize
      @usage = $0
      @description = nil
      @arguments = []
      @options = []
      @flags = []
      @examples = []
      yield self if block_given?
    end

    # Gets or sets the usage for your program. If the
    # provided usage is nil, the usage will not change.
    # @param usage [String,nil] sets the usage if not nil
    # @return [String] usage
    # @example
    #   Argy.new do |o|
    #     o.usage "example [INPUT]"
    #   end
    def usage(usage = nil)
      @usage = usage if usage
      @usage
    end

    # Gets or sets a description for your program. If the
    # provided description is nil, the description will
    # not change.
    # @param description [String,nil]
    # @return [String]
    # @example
    #   Argy.new do |o|
    #     o.description "a really useful program"
    #   end
    def description(description = nil)
      @description = description if description
      @description
    end

    # Adds an example
    # @example
    #   Argy.new do |o|
    #     o.example "$ example foo"
    #   end
    def example(example)
      @examples << example
    end

    # Adds an argument
    # @see Argument#initialize
    # @example
    #   Argy.new do |o|
    #     o.argument :input
    #   end
    def argument(*args)
      @arguments << Argument.new(*args)
    end

    # Adds an option
    # @see Option#initialize
    # @example
    #   Argy.new do |o|
    #     o.option :verbose, type: :boolean
    #   end
    def option(*args)
      @options << Option.new(*args)
    end

    # Adds a flag
    # @example
    #   Argy.new do |o|
    #     o.on "-v", "--version" do
    #       puts Example::VERSION
    #       exit
    #     end
    #   end
    def on(*args, &action)
      @flags << [args, action]
    end

    # All parameters that are defined
    # @return [Array<Argument, Option>]
    def parameters
      arguments + options
    end

    # Generate help for this parser.
    # @see Help#initialize
    # @return [Help]
    def help(**opts)
      Help.new(self, **opts)
    end

    # Build the default values for the declared paramters.
    # @return [Hash{Symbol => Object}]
    def default_values
      parameters.reduce(unused_args: []) do |acc, opt|
        acc[opt.name] = opt.default
        acc
      end
    end

    # Build the default values for the declared paramters.
    # @param argv [Array<String>] the command line arguments to parse
    # @param strategy [Symbol,nil] can be either `:order` or `:permute`. See
    #   `OptionParser#order!` and `OptionParser#permute!` for more info.
    # @raise [ParseError] when the arguments can't be parsed
    # @return [Hash{Symbol => Object}]
    def parse(argv, strategy: nil)
      argv = argv.dup
      values = default_values
      parser = build_parser(values)

      case strategy
      when :order
        parser.order!(argv)
      when :permute
        parser.permute!(argv)
      else
        parser.parse!(argv)
      end

      populate_arguments(values, argv)
      Options.new validate!(values)
    rescue OptionParser::ParseError => error
      raise ParseError.new(error)
    end

    # Validate the values
    # @param values [Hash{Symbol => Object}]
    # @return [Hash{Symbol => Object}]
    # @raise [ValidationError] when the input is invalid
    def validate!(values)
      parameters.each do |param|
        param.validate(values[param.name])
      end
      values
    end

    private

    def populate_arguments(values, argv)
      argv.zip(arguments).each do |value, arg|
        if arg.nil?
          values[:unused_args] << value
        else
          values[arg.name] = arg.coerce(value)
        end
      end
    end

    def build_parser(values)
      OptionParser.new do |o|
        options.each do |opt|
          o.on(*opt.to_option_parser) do |value|
            values[opt.name] = opt.coerce(value)
          end
        end

        flags.each do |flag, action|
          o.on(*flag, &action)
        end
      end
    end
  end
end
