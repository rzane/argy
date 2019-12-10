require "argy/options"

RSpec.describe Argy::Options do
  it "reads options" do
    opts = Argy::Options.new(value: 1)
    expect(opts.value).to eq(1)
  end

  it "raises NoMethodError for non-options" do
    opts = Argy::Options.new({})
    expect{ opts.value }.to raise_error(NoMethodError)
  end

  it "raises ArgumentError for additional arguments" do
    opts = Argy::Options.new(value: 1)
    expect { opts.value(:foo) }.to raise_error(ArgumentError)
  end

  it "queries for truthy options" do
    opts = Argy::Options.new(value: 1)
    expect(opts.value?).to be(true)
  end

  it "queries for nil options" do
    opts = Argy::Options.new(value: nil)
    expect(opts.value?).to be(false)
  end

  it "queries for false options" do
    opts = Argy::Options.new(value: false)
    expect(opts.value?).to be(false)
  end

  it "queries for non-options" do
    opts = Argy::Options.new({})
    expect(opts.value?).to be(false)
  end

  it "reads an option with hash syntax" do
    opts = Argy::Options.new(value: 1)
    expect(opts[:value]).to eq(1)
  end

  it "reads an non-option with hash syntax" do
    opts = Argy::Options.new({})
    expect(opts[:value]).to be_nil
  end

  it "fetches an option" do
    opts = Argy::Options.new(value: 1)
    expect(opts.fetch(:value)).to eq(1)
  end

  it "fetches a non-option" do
    opts = Argy::Options.new({})
    expect { opts.fetch(:value) }.to raise_error(KeyError)
  end

  it "fetches an option with a default" do
    opts = Argy::Options.new({})
    expect(opts.fetch(:value, 1)).to eq(1)
  end

  it "fetches an option with a default block" do
    opts = Argy::Options.new({})
    expect(opts.fetch(:value) { 1 }).to eq(1)
  end
end
