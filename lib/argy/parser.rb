require "optparse"
require "argy/option"
require "argy/argument"

module Argy
  class Parser
    attr_reader :examples, :arguments, :options

    def initialize
      @usage = $0
      @version = nil
      @description = nil
      @arguments = []
      @options = []
      @examples = []
      yield self if block_given?
    end

    def usage(usage = nil)
      @usage = usage if usage
      @usage
    end

    def version(version = nil)
      @version = version if version
      @version
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

    def parameters
      arguments + options
    end

    def help
    end

    def default_values
      (arguments + options).reduce(unused_arguments: []) do |acc, opt|
        acc[opt.name] = opt.default
        acc
      end
    end

    def parse(argv)
      argv = argv.dup
      values = default_values

      parser = build_parser(values)
      parser.order!(argv)

      populate_arguments(values, argv)
      validate!(values)

      values
    end

    private

    def populate_arguments(values, argv)
      argv.zip(arguments).each do |value, arg|
        if arg.nil?
          values[:unused_arguments] << value
        else
          values[arg.name] = arg.coerce(value)
        end
      end
    end

    def build_parser(values)
      OptionParser.new do |parser|
        options.each do |opt|
          parser.on(*opt.to_option_parser) do |value|
            values[opt.name] = opt.coerce(value)
          end
        end

        if version
          parser.on_tail("-v", "--version", "show version and exit") do
            puts version
            exit
          end
        end

        parser.on_tail("-h", "--help", "show this help and exit") do
          puts help
          exit
        end
      end
    end

    def validate!(values)
      parameters.each do |param|
        param.validate(values[param.name])
      end
    end
  end
end
