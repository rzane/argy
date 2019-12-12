module Argy
  class Help
    def initialize(parser, column: 30, color: $stdout.tty?)
      @parser = parser
      @column = column
      @color = color
    end

    def to_s
      out = []

      description(out)
      usage(out)
      examples(out)
      arguments(out)
      options(out)
      flags(out)

      out.join("\n") + "\n"
    end

    def section(title)
      bold "\n#{title}"
    end

    def entry(name, desc: nil, required: false, default: nil)
      out = "  #{name.ljust(column)}"
      out += dim("#{desc} ") if desc
      out += dim("(required) ") if required
      out += dim("[default: #{default.inspect}]") if default
      out.rstrip
    end

    private

    def description(out)
      out << "#{parser.description}\n" if parser.description
    end

    def usage(out)
      out << bold("USAGE")
      out << "  #{parser.usage}"
    end

    def examples(out)
      out << bold("\nEXAMPLES") if parser.examples.any?
      out.concat parser.examples.map { |ex| "  #{ex}" }
    end

    def arguments(out)
      out << bold("\nARGUMENTS") if parser.arguments.any?
      out.concat parser.arguments.map { |a| argument(a) }
    end

    def argument(a)
      entry(a.label, desc: a.desc, required: a.required?, default: a.default)
    end

    def options(out)
      out << bold("\nOPTIONS") if parser.options.any?
      out.concat parser.options.map { |o| option(o) }
    end

    def option(o)
      label = [option_label(o.label, o.type)]
      label += o.aliases.map { |a| option_label(a, o.type) }
      entry(label.join(", "), desc: o.desc, required: o.required?, default: o.default)
    end

    def flags(out)
      out << bold("\nFLAGS") if parser.flags.any?
      out.concat parser.flags.map { |f, _| flag(f) }
    end

    def flag(flag)
      flag = flag.dup
      desc = flag.pop unless flag.last.match?(/^-/)
      entry(flag.reverse.join(", "), desc: desc)
    end

    def option_label(label, type)
      return label if type == :boolean
      label.start_with?("--") ? "#{label}=VALUE" : "#{label} VALUE"
    end

    def bold(text)
      color? ? "\e[1m#{text}\e[0m" : text
    end

    def dim(text)
      color? ? "\e[2m#{text}\e[0m" : text
    end

    def color?
      @color
    end

    attr_reader :parser, :column
  end
end
