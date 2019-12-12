require "argy/version"
require "argy/parser"

module Argy
  Error = Class.new(StandardError)
  CoersionError = Class.new(Error)
  ValidationError = Class.new(Error)

  class ParseError < Error
    attr_reader :original

    def initialize(original)
      @original = original
      super(original.message)
    end
  end

  def self.new(**opts, &block)
    Argy::Parser.new(opts, &block)
  end

  def self.parse(argv: ARGV, **opts, &block)
    new(opts, &block).parse(argv)
  end
end
