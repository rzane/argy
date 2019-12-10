module Argy
  class Options
    def initialize(values)
      @values = values
    end

    def to_h
      @values
    end

    def [](key)
      @values[key]
    end

    def fetch(*args, &block)
      @values.fetch(*args, &block)
    end

    private

    def respond_to_missing?(meth, *)
      @values.key?(meth.to_s.sub(/\?$/, "").to_sym) || super
    end

    def method_missing(meth, *args)
      query = meth[-1] == "?"
      key = query ? meth[0..-2].to_sym : meth.to_sym

      return super unless @values.key?(key)

      unless args.empty?
        raise ArgumentError, "wrong number of arguments (given #{args.length}, expected 0)"
      end

      query ? !!@values[key] : @values[key]
    end
  end
end
