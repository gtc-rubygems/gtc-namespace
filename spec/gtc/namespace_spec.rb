# frozen_string_literal: true

RSpec.describe GTC::Namespace do
  describe '.version' do
    it "returns a gem version" do
      expect(GTC::Namespace.version).to be_a Gem::Version
    end

    it "has a version number" do
      expect(GTC::Namespace.version.to_s).to eq GTC::Namespace::VERSION::STRING
    end
  end
end
