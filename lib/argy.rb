require "argy/version"
require "argy/parser"

module Argy
  # Base class for all of Argy's errors.
  Error = Class.new(StandardError)

  # An error that is raised when an option
  # cannot be coerced to the correct type
  CoersionError = Class.new(Error)

  # An error that is raised when an option
  # is not valid.
  ValidationError = Class.new(Error)

  # An error that is raised when parsing fails.
  class ParseError < Error
    # The original error from OptionParser.
    # @return [OptionParser::ParseError]
    attr_reader :original

    def initialize(original)
      @original = original
      super(original.message)
    end
  end

  # Define a new parser.
  # @see Parser
  # @example
  #   parser = Argy.new do |o|
  #     o.argument :input, desc: "the input file"
  #     o.option :verbose, type: :boolean
  #   end
  #
  #   options = parser.parse(ARGV)
  def self.new(&block)
    Argy::Parser.new(&block)
  end

  # Define a parser and return the options in one go.
  # @see Parser
  # @example
  #   options = Argy.parse do
  #     o.argument :input, desc: "the input file"
  #     o.option :verbose, type: :boolean
  #   end
  def self.parse(argv: ARGV, &block)
    new(&block).parse(argv)
  end
end
