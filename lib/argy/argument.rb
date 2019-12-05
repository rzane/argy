require "argy/parameter"

module Argy
  class Argument < Parameter
    def label
      name.to_s.upcase
    end
  end
end
