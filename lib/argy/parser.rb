require "optparse"
require "argy/help"
require "argy/option"
require "argy/argument"
require "argy/options"

module Argy
  class Parser
    attr_reader :examples, :arguments, :options, :flags

    def initialize
      @usage = $0
      @description = nil
      @arguments = []
      @options = []
      @flags = []
      @examples = []
      yield self if block_given?
    end

    def usage(usage = nil)
      @usage = usage if usage
      @usage
    end

    def description(description = nil)
      @description = description if description
      @description
    end

    def example(example)
      @examples << example
    end

    def argument(*args)
      @arguments << Argument.new(*args)
    end

    def option(*args)
      @options << Option.new(*args)
    end

    def on(*args, &action)
      @flags << [args, action]
    end

    def parameters
      arguments + options
    end

    def help(**opts)
      Help.new(self, **opts)
    end

    def default_values
      (arguments + options).reduce(args: []) do |acc, opt|
        acc[opt.name] = opt.default
        acc
      end
    end

    def parse(argv)
      argv = argv.dup
      values = default_values

      parser = build_parser(values)
      parser.parse!(argv)

      populate_arguments(values, argv)
      validate!(values)

      Options.new(values)
    rescue OptionParser::MissingArgument => error
      raise MissingArgumentError, error.message
    end

    def validate!(values)
      parameters.each do |param|
        param.validate(values[param.name])
      end
      nil
    end

    private

    def populate_arguments(values, argv)
      argv.zip(arguments).each do |value, arg|
        if arg.nil?
          values[:args] << value
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

        o.on("-h", "--help") do
          puts help
          exit
        end
      end
    end
  end
end
