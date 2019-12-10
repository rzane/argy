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
      meth[-1] == "?" || @values.key?(meth) || super
    end

    def method_missing(meth, *args)
      query = meth[-1] == "?"
      key = query ? meth[0..-2].to_sym : meth.to_sym

      return !!@values[key] if query
      return super unless @values.key?(key)
      return @values[key] if args.empty?
      raise ArgumentError, "wrong number of arguments (given #{args.length}, expected 0)"
    end
  end
end
