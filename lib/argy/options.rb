module Argy
  # The resulting options that were parsed from the command line.
  # @example Getting a value
  #   options = Options.new(foo: "bar")
  #   options.foo #=> "bar"
  # @example Querying for a value's truthiness
  #   options = Options.new(foo: "bar")
  #   options.foo? #=> true
  class Options
    # Create a new Options
    # @param values [Hash{Symbol => Object}]
    def initialize(values)
      @values = values
    end

    # The values as a hash
    # @return [Hash{Symbol => Object}]
    def to_h
      @values
    end

    # Get a value by key
    # @see Hash#[]
    def [](key)
      @values[key]
    end

    # Fetch a value by key or provide a default.
    # @see Hash#fetch
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
