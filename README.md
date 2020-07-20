<h1 align="center">Argy</h1>

<div align="center">

![Build](https://github.com/rzane/argy/workflows/Build/badge.svg)
![Version](https://img.shields.io/gem/v/argy)
[![Coverage Status](https://coveralls.io/repos/github/rzane/argy/badge.svg?branch=master)](https://coveralls.io/github/rzane/argy?branch=master)

</div>

Yet another command-line option parser.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'argy'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install argy

## Usage

Here's an example:

```ruby
require "argy"

parser = Argy.new do |o|
  o.description "Prints messages"
  o.usage "example"
  o.example "$ example hello"

  o.argument :message, desc: "message to print", required: true

  o.option :loud, type: :boolean, desc: "say the message loudly"
  o.option :count, type: :integer, desc: "number of times to print", default: 1

  o.on "-v", "print the verison and exit" do
    puts Example::VERSION
    exit
  end

  o.on "-h", "--help", "show this help and exit" do
    puts o.help
    puts o.help.section "SECTION"
    puts o.help.entry "foo", desc: "bar"
    exit
  end
end

begin
  options = parser.parse(ARGV)
  message = options.message
  message = message.upcase if options.loud?
  options.count.times { puts message }
rescue Argy::Error => err
  abort err.message
end
```

## Option Types

Argy supports the following option types:

- `:string`
- `:boolean`
- `:integer`
- `:float`
- `:array`
- `:pathname`

However, Argy also supports custom option types. For example:

```ruby
class NameOption
  def self.call(input)
    parts = input.split(" ")
    raise Argy::CoersionError, "Invalid name" if parts.length != 2
    new(*parts)
  end

  def initialize(first, last)
    @first = first
    @last = last
  end
end

Argy.new do |o|
  o.option :name, type: NameOption
end
```

An option type is anything that responds to `call`. So, your option type could just be a lambda.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rzane/argy. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Argy project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/rzane/argy/blob/master/CODE_OF_CONDUCT.md).
