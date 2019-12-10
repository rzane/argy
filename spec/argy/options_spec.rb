require "argy/options"

RSpec.describe Argy::Options do
  describe "reader methods" do
    it "reads options" do
      opts = Argy::Options.new(value: 1)
      expect(opts.value).to eq(1)
    end

    it "raises NoMethodError for non-options" do
      opts = Argy::Options.new({})
      expect{ opts.value }.to raise_error(NoMethodError)
    end

    it "raises ArgumentError for too many arguments" do
      opts = Argy::Options.new(value: 1)
      expect { opts.value(:foo) }.to raise_error(ArgumentError)
    end
  end

  describe "query methods" do
    it "queries for truthy options" do
      opts = Argy::Options.new(value: 1)
      expect(opts.value?).to be(true)
    end

    it "queries for false options" do
      opts = Argy::Options.new(value: false)
      expect(opts.value?).to be(false)
    end

    it "queries for nil options" do
      opts = Argy::Options.new(value: nil)
      expect(opts.value?).to be(false)
    end

    it "raises a NoMethodError for non-options" do
      opts = Argy::Options.new({})
      expect { opts.value? }.to raise_error(NoMethodError)
    end

    it "raises an ArgumentError for too many arguments" do
      opts = Argy::Options.new(value: 1)
      expect { opts.value?(:foo) }.to raise_error(ArgumentError)
    end
  end

  describe "#respond_to?" do
    it "responds to option names" do
      opts = Argy::Options.new(value: 1)
      expect(opts.respond_to?(:value)).to be(true)
    end

    it "reponds to queries for option names" do
      opts = Argy::Options.new(value: 1)
      expect(opts.respond_to?(:value?)).to be(true)
    end

    it "does not respond to non-option names" do
      opts = Argy::Options.new({})
      expect(opts.respond_to?(:value)).to be(false)
    end

    it "does not respond to queries for non-option names" do
      opts = Argy::Options.new({})
      expect(opts.respond_to?(:value?)).to be(false)
    end
  end

  describe "#[]" do
    it "gets an option" do
      opts = Argy::Options.new(value: 1)
      expect(opts[:value]).to eq(1)
    end

    it "gets a non-option" do
      opts = Argy::Options.new({})
      expect(opts[:value]).to be_nil
    end
  end

  describe "#fetch" do
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
end
