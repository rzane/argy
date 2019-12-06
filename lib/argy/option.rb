require "argy/parameter"

module Argy
  class Option < Parameter
    attr_reader :aliases

    def initialize(*args, aliases: [], **opts)
      super(*args, **opts)
      @aliases = aliases
    end

    def label
      case type
      when :boolean
        "--[no-]#{name.to_s.tr("_", "-")}"
      else
        "--#{name.to_s.tr("_", "-")}"
      end
    end

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
