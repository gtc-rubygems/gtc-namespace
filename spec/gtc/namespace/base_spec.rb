# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GTC::Namespace::Base do
  describe '.resolve' do
    it 'resolves a module' do
      expect(
        GTC::Namespace::Base.resolve(:dummy, 'cell', 'Show')
      ).to be Dummy::Cell::Show
    end
  end

  describe '.path' do
    it 'returns a path string' do
      expect(
        GTC::Namespace::Base.path(:dummy, 'cell', 'Index')
      ).to eq 'Dummy::Cell::Index'
    end
  end

  describe '.build' do
    it 'builds and returns a new module' do
      expect{
        Dummy::Commands::Enter
      }.to raise_exception

      expect(
        GTC::Namespace::Base.build(:hammer, 'commands', 'Enter').to_s
      ).to eq 'Hammer::Command::Enter'
    end
  end

  describe '.transform' do
    it 'converts to a new module' do
      expect(
        GTC::Namespace::Base.transform(Dummy::Cell::Index, [:__resource, :endpoint, :__handle])
      ).to be Dummy::Endpoint::Index

      expect(
        GTC::Namespace::Base.transform(Dummy::Cell::Index, [:__resource, :__section, :__handle])
      ).to be Dummy::Dummy::Index

      expect(
        GTC::Namespace::Base.transform(Dummy::Cell, [:__scope, 'UsersController'])
      ).to be Dummy::UsersController
    end

    it 'returns module path' do
      expect(
        GTC::Namespace::Base.transform(Dummy::UsersController, [:__concept, :test], false)
      ).to eq 'Controller::Test'

      expect(
        GTC::Namespace::Base.transform(Dummy::Cell::Index, [:__resource, :__service, :__handle], false)
      ).to eq 'Dummy::Cell::Index'
    end
  end

  describe '.components' do
    it 'returns a array' do
      expect(
        GTC::Namespace::Base.components(Dummy::Cell::Index)
      ).to eq [Dummy, Dummy::Cell, Dummy::Cell::Index]
    end
  end

  describe '.modules' do
    it 'returns a array' do
      expect(
        GTC::Namespace::Base.modules(Dummy::Cell::Index)
      ).to eq ['Dummy','Cell','Index']
    end
  end

  describe '.sections' do
    it 'returns a array' do
      expect(
        GTC::Namespace::Base.sections(Dummy::Cell::Index)
      ).to eq [:dummy, :cell, :index]
    end
  end

  describe '.scope' do
    it 'returns the module scope' do
      expect(
        GTC::Namespace::Base.scope(Dummy::Cell::Index)
      ).to eq :dummy

      expect(
        GTC::Namespace::Base.scope(Dummy::Endpoint)
      ).to eq :dummy
    end

    it 'returns nil single modules' do
      expect(
        GTC::Namespace::Base.scope(Dummy)
      ).to be_nil
    end

  end

  describe '.concept' do
    it 'returns the concept name' do
      expect(
        GTC::Namespace::Base.concept(Dummy::AnotherChild)
      ).to eq :child

      expect(
        GTC::Namespace::Base.concept(Dummy::UsersController)
      ).to eq :controller
    end

    it 'returns nil for none concepts' do
      expect(
        GTC::Namespace::Base.concept(Dummy::Cell::Index)
      ).to be_nil

      expect(
        GTC::Namespace::Base.concept(Dummy::Cell::Index)
      ).to be_nil
    end
  end

  describe '.resource' do
    it 'returns the resource name for short modules' do
      expect(
        GTC::Namespace::Base.resource(Dummy::UsersController)
      ).to eq :user
    end

    it 'returns the resource name for long modules' do
      expect(
        GTC::Namespace::Base.resource(Dummy::Resolver::UserHandler::Cmd::Import)
      ).to eq :user_handler
    end

    it 'returns first module resource' do
      expect(
        GTC::Namespace::Base.resource(Dummy::Cell::Index)
      ).to eq :dummy

      expect(
        GTC::Namespace::Base.resource(Dummy)
      ).to eq :dummy
    end
  end

  describe '.section' do
    it 'returns the default section' do
      expect(
        GTC::Namespace::Base.section(Dummy::Cell::Index)
      ).to eq :dummy
    end

    it 'returns the first section' do
      expect(
        GTC::Namespace::Base.section(Dummy::Cell::Index, 0)
      ).to eq :dummy
    end

    it 'returns the second section' do
      expect(
        GTC::Namespace::Base.section(Dummy::Cell::Index, -2)
      ).to eq :cell
    end
  end

  describe '.service' do
    it 'returns the service name' do
      expect(
        GTC::Namespace::Base.service(Dummy::Cell::Index)
      ).to eq :cell
    end

    it 'returns nil for too few modules' do
      expect(
        GTC::Namespace::Base.service(Dummy::UsersController)
      ).to be_nil
    end
  end

  describe '.handle' do
    it 'returns the handle name' do
      expect(
        GTC::Namespace::Base.handle(Dummy::Cell::Index)
      ).to eq :index
    end

    it 'returns nil for too few modules' do
      expect(
        GTC::Namespace::Base.handle(Dummy::UsersController)
      ).to be_nil
    end
  end

  describe 'instance methods' do
    before :all do
      @klass = Dummy::Cell::Index
    end

    it '#components' do
      expect(
        @klass.namespace.components
      ).to eq [Dummy, Dummy::Cell, Dummy::Cell::Index]
    end

    it '#modules' do
      expect(
        @klass.namespace.modules
      ).to eq ['Dummy','Cell','Index']
    end

    it '#sections' do
      expect(
        @klass.namespace.sections
      ).to eq [:dummy, :cell, :index]
    end

    it '#scope' do
      expect(
        @klass.namespace.scope
      ).to eq :dummy
    end

    it '#concept' do
      expect(
        @klass.namespace.concept
      ).to eq nil
    end

    it '#resource' do
      expect(
        @klass.namespace.resource
      ).to eq :dummy
    end

    it '#section' do
      expect(
        @klass.namespace.section
      ).to eq :dummy

      expect(
        @klass.namespace.section(-1)
      ).to eq :index
    end

    it '#service' do
      expect(
        @klass.namespace.service
      ).to eq :cell
    end

    it '#handle' do
      expect(
        @klass.namespace.handle
      ).to eq :index
    end

    it '#transform' do
      expect(
        @klass.namespace.transform([:__resource, :__section, :__handle])
      ).to be Dummy::Dummy::Index
    end


    it '#info' do
      expect{
        @klass.namespace.info
      }.to output(<<~OUT).to_stdout
-----------------------------------------------------------------------------------------------
=> Dummy::Cell::Index <=
components: [Dummy, Dummy::Cell, Dummy::Cell::Index]
modules   : ["Dummy", "Cell", "Index"]
sections  : [:dummy, :cell, :index]
scope     : dummy
concept   : 
resource  : dummy
service   : cell
handle    : index
-----------------------------------------------------------------------------------------------
      OUT
    end
  end

  describe '.info' do
    it 'prints info' do
      expect{
        GTC::Namespace::Base.info(Dummy::Cell::Index)
      }.to output(<<~OUT).to_stdout
-----------------------------------------------------------------------------------------------
=> Dummy::Cell::Index <=
components: [Dummy, Dummy::Cell, Dummy::Cell::Index]
modules   : ["Dummy", "Cell", "Index"]
sections  : [:dummy, :cell, :index]
scope     : dummy
concept   : 
resource  : dummy
service   : cell
handle    : index
-----------------------------------------------------------------------------------------------
OUT
    end
  end
end