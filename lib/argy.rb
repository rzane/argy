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

  def self.new(&block)
    Argy::Parser.new(&block)
  end

  def self.parse(argv, &block)
    new(&block).parse(argv)
  end
end
