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
      deindent build_parser({}).to_s
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

    def validate!(values)
      parameters.each do |param|
        param.validate(values[param.name])
      end
    end

    def build_parser(values)
      OptionParser.new bold("USAGE") do |o|
        o.separator "  #{usage}"

        if description
          o.separator bold("\nDESCRIPTION")
          o.separator "  #{description}"
        end

        o.separator bold("\nEXAMPLES") if examples.any?
        examples.each do |ex|
          o.separator "  #{ex}"
        end

        o.separator bold("\nARGUMENTS") if arguments.any?
        arguments.each do |arg|
          o.separator "  #{arg.label}#{arg.desc&.rjust(39)}"
        end

        o.separator bold("\nOPTIONS") if arguments.any?
        options.each do |opt|
          o.on(*opt.to_option_parser) do |value|
            values[opt.name] = opt.coerce(value)
          end
        end

        o.separator bold("\nFLAGS")
        if version
          o.on_tail("-v", "--version", "show version and exit") do
            puts version
            exit
          end
        end

        o.on_tail("-h", "--help", "show this help and exit") do
          puts deindent(o.to_s)
          exit
        end
      end
    end

    def deindent(out)
      out.gsub(/^    /, "  ")
    end

    def bold(value)
      if $stdout.tty?
        "\e[1m#{value}\e[0m"
      else
        value
      end
    end
  end
end
