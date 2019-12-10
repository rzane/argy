require "argy"

RSpec.describe Argy do
  subject(:parser) { Argy.new }

  it "parses an option" do
    parser.option :value
    expect(parser.parse(["--value", "foo"]).to_h).to have_values(value: "foo")
  end

  it "parses a boolean option" do
    parser.option :value, type: :boolean
    expect(parser.parse(["--value"]).to_h).to have_values(value: true)
    expect(parser.parse(["--no-value"]).to_h).to have_values(value: false)
  end

  it "parses an integer option" do
    parser.option :value, type: :integer
    expect(parser.parse(["--value", "1"]).to_h).to have_values(value: 1)
  end

  it "parses a float option" do
    parser.option :value, type: :float
    expect(parser.parse(["--value", "1.1"]).to_h).to have_values(value: 1.1)
  end

  it "parses an array option" do
    parser.option :value, type: :array
    expect(parser.parse(["--value", "one,two"]).to_h).to have_values(value: ["one", "two"])
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
    expect(parser.parse(["--value", "foo"]).to_h).to have_values(value: "custom foo")
  end

  it "parses a positional arguments" do
    parser.argument :foo
    parser.argument :bar
    expect(parser.parse(["foo"]).to_h).to have_values(foo: "foo", bar: nil)
  end

  it "respects aliases" do
    parser.option :value, aliases: ["-v"]
    expect(parser.parse(["-v", "foo"]).to_h).to have_values(value: "foo")
  end

  it "respects default values" do
    parser.option :value, default: "foo"
    expect(parser.parse([]).to_h).to have_values(value: "foo")
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
    parser.option :output
    parser.argument :name
    options = parser.parse %w(foo --output src unused)
    expect(options.to_h).to eq(name: "foo", output: "src", args: ["unused"])
  end

  it "raises a custom error when coersion fails" do
    parser.option :value, type: :integer
    expect { parser.parse(["--value", ""]) }.to raise_error(
      Argy::CoersionError,
      "`--value` received an invalid value"
    )
  end

  it "raises a custom error when an argument is missing" do
    parser.option :value, type: :integer
    expect { parser.parse(["--value"]) }.to raise_error(
      Argy::MissingArgumentError,
      "missing argument: --value"
    )
  end

  it "generates help" do
    parser.usage "example"
    parser.example "$ example foo"
    parser.argument :jint, desc: "do a thing"
    parser.option :fizz, required: true, desc: "blah"
    parser.option :foo_bar, aliases: ["-f"]
    parser.on("-v", "show the version and exit") {}

    expect(parser.help(color: false).to_s).to eq(<<~EOS)
      USAGE
        example

      EXAMPLES
        $ example foo

      ARGUMENTS
        JINT                          do a thing

      OPTIONS
        --fizz=VALUE                  blah (required)
        --foo-bar=VALUE, -f VALUE

      FLAGS
        -v                            show the version and exit
        --help, -h                    show this help and exit
    EOS
  end

  def have_values(**values)
    eq(args: [], **values)
  end
end
