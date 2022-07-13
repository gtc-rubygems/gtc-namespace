# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Object extensions' do
  describe '.namespace' do
    it "returns a fresh namespace instance" do
      expect(::Numeric.namespace).to be_a GTC::Namespace::Base
      expect(Dummy::Base.namespace).to_not eq Dummy::Base.namespace
    end

    it "returns namespace for class" do
      expect(Dummy::Base.namespace.resource).to be :dummy
    end

    it "returns namespace for instance" do
      expect(Dummy::Base.new.namespace.resource).to be :dummy
    end
  end
end