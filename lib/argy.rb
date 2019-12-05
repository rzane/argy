require "argy/version"
require "argy/parser"

module Argy
  Error = Class.new(StandardError)
  CoersionError = Class.new(Error)
  ValidationError = Class.new(Error)

  def self.new(&block)
    Argy::Parser.new(&block)
  end

  def self.parse(argv, &block)
    build(&block).parse(argv)
  end
end
