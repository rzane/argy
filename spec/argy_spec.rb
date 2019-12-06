require "argy"

RSpec.describe Argy do
  subject(:parser) { Argy.new }

  it "parses an option" do
    parser.option :value
    expect(parser.parse(["--value", "foo"])).to have_values(value: "foo")
  end

  it "parses a boolean option" do
    parser.option :value, type: :boolean
    expect(parser.parse(["--value"])).to have_values(value: true)
    expect(parser.parse(["--no-value"])).to have_values(value: false)
  end

  it "parses an integer option" do
    parser.option :value, type: :integer
    expect(parser.parse(["--value", "1"])).to have_values(value: 1)
  end

  it "parses a float option" do
    parser.option :value, type: :float
    expect(parser.parse(["--value", "1.1"])).to have_values(value: 1.1)
  end

  it "parses an array option" do
    parser.option :value, type: :array
    expect(parser.parse(["--value", "one,two"])).to have_values(value: ["one", "two"])
  end

  it "parses a pathname" do
    parser.option :value, type: :pathname
    options = parser.parse(["--value", "/"])
    value = options.fetch(:value)
    expect(value).to be_a(Pathname)
    expect(value.to_s).to eq("/")
  end

  it "parses a custom option" do
    parser.option :value, type: ->(value) { "custom #{value}" }
    expect(parser.parse(["--value", "foo"])).to have_values(value: "custom foo")
  end

  it "parses a positional arguments" do
    parser.argument :foo
    parser.argument :bar
    expect(parser.parse(["foo"])).to have_values(foo: "foo", bar: nil)
  end

  it "respects aliases" do
    parser.option :value, aliases: ["-v"]
    expect(parser.parse(["-v", "foo"])).to have_values(value: "foo")
  end

  it "respects default values" do
    parser.option :value, default: "foo"
    expect(parser.parse([])).to have_values(value: "foo")
  end

  it "respects missing arguments" do
    parser.argument :value, required: true
    expect { parser.parse([]) }.to raise_error(
      Argy::ValidationError,
      "`VALUE` is a required parameter"
    )
  end

  it "respects required options" do
    parser.option :value, required: true
    expect { parser.parse([]) }.to raise_error(
      Argy::ValidationError,
      "`--value` is a required parameter"
    )
  end

  it "keeps unused arguments" do
    parser.argument :foo
    options = parser.parse %w(foo bar -f buzz)
    expect(options).to eq(foo: "foo", unused_arguments: ["bar", "-f", "buzz"])
  end

  it "raises a custom error when coersion fails" do
    parser.option :value, type: :integer
    expect { parser.parse(["--value", ""]) }.to raise_error(
      Argy::CoersionError,
      "`--value` received an invalid value"
    )
  end

  it "generates help" do
    parser.usage "example"
    parser.example "$ example foo"
    parser.version "0.0.0"
    parser.argument :jint, desc: "do a thing"
    parser.option :fizz, required: true, desc: "blah"
    parser.option :foo_bar, aliases: ["-f"]

    expect(strip_ansi(parser.help)).to eq(<<~EOS)
      USAGE
        example

      EXAMPLES
        $ example foo

      ARGUMENTS
        JINT                             do a thing

      OPTIONS
            --fizz FIZZ                  blah (required)
        -f, --foo-bar FOO_BAR

      FLAGS
        -v, --version                    show version and exit
        -h, --help                       show this help and exit
    EOS
  end

  def strip_ansi(out)
    out.gsub(/\e\[\d+m/, "")
  end

  def have_values(**values)
    eq(unused_arguments: [], **values)
  end
end
