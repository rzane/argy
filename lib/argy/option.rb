require "argy/parameter"

module Argy
  class Option < Parameter
    def label
      "--#{name.to_s.tr("_", "-")}"
    end

    def to_option_parser
      options = []
      options << aliases.join(" ") unless aliases.empty?

      case type
      when :boolean
        options << label.sub(/^--/, "--[no-]")
      else
        options << "#{label}=#{name.to_s.upcase}"
        options << "#{label} #{name.to_s.upcase}"
      end

      options << desc if desc
      options
    end
  end
end
