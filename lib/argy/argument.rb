require "argy/parameter"

module Argy
  # An positional argument to be parsed from the command line
  class Argument < Parameter
    # The display label for the argument
    # @return [String]
    def label
      name.to_s.upcase
    end
  end
end
